import 'package:flutter/material.dart';
// import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:telephony/telephony.dart';
import '../components/customScaffold.dart';


class ExpenseTrackerPage extends StatefulWidget {
  @override
  _ExpenseTrackerPageState createState() => _ExpenseTrackerPageState();
}

class _ExpenseTrackerPageState extends State<ExpenseTrackerPage> with SingleTickerProviderStateMixin {
  final Telephony telephony = Telephony.instance;
  final StreamController<List<SmsMessage>> _smsStreamController = StreamController<List<SmsMessage>>();
  List<SmsMessage> _allMessages = [];
  List<SmsMessage> _messages = [];
  List<Map<String, dynamic>> _filteredTransactions = [];
  late TabController _tabController;
  late StreamSubscription<List<SmsMessage>> _smsSubscription;

  @override
  void initState() {
    super.initState();
    _getSmsPermissionAndListen(context);
    _tabController = TabController(length: 2, vsync: this);
    _smsSubscription = _smsStreamController.stream.listen((messages) {
      setState(() {
        _messages = messages;
        _filterTransactions(-1); // Default to "All"
      });
    });
  }

  @override
  void dispose() {
    _smsSubscription.cancel();
    _smsStreamController.close();
    super.dispose();
  }

  // Future<void> _getSmsPermissionAndListen() async {
  //   var status = await Permission.sms.status;
  //   if (status.isDenied) {
  //     status = await Permission.sms.request();
  //   }
  //
  //   if (status.isGranted) {
  //     List<SmsMessage> newMessages = await _smsQuery.getAllSms;
  //     newMessages.sort((a, b) {
  //       // Use `compareTo` in reverse order to get descending sort
  //       return (b.date ?? DateTime.now()).compareTo(a.date ?? DateTime.now());
  //     });
  //     _smsStreamController.add(newMessages);
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("SMS permission denied!")),
  //     );
  //   }
  // }

  // -------------------------------------------------
  Future<void> _getSmsPermissionAndListen(BuildContext context) async {
    // Request SMS and phone permissions
    bool? permissionsGranted = await telephony.requestPhoneAndSmsPermissions;

    if (permissionsGranted == true) {
      // Set up real-time SMS listener
      telephony.listenIncomingSms(
        onNewMessage: (SmsMessage message) {
          _handleNewSms(message);
        },
        onBackgroundMessage: _onBackgroundMessage, // Optional background handler
      );

      // Fetch initial SMS messages from inbox
      List<SmsMessage> newMessages = await telephony.getInboxSms();
      _allMessages = newMessages;
      _smsStreamController.add(_allMessages);
    } else {
      // Notify the user if permission is denied
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("SMS permission denied!")),
      );
    }
  }

  void _handleNewSms(SmsMessage message) {
    _allMessages.insert(0, message); // Add new SMS to the beginning of the list
    _filterTransactions(-1);
    _smsStreamController.add(_allMessages); // Emit the updated list to the stream
    setState(() {});
  }

  static Future<void> _onBackgroundMessage(SmsMessage message) async {
    print("Background SMS received: ${message.body}");
  }

  static const accountNumbers = ["8378","3806"];
  static const debitKeywords = ["Amt Sent","debited", "withdrawn", "Sent Rs."];
  static const creditKeywords = ["credited to", "deposited","CREDITED to"];

  void _filterTransactions(int selectedMonth) {
    final now = DateTime.now();
    final currentYear = now.year;


    setState(() {
      // Filter and map messages into transactions
      _filteredTransactions = _messages
          .map((message) {
        final body = message.body?.toLowerCase() ?? "";
        if (!accountNumbers.any((account) => body.contains(account.toLowerCase()))) {
          return null; // Skip messages not related to specified accounts
        }

        String? type;
        double? creditAmount;
        double? debitAmount;

        // Convert `message.date` (int) to `DateTime`
        DateTime? transactionDate = message.date != null
            ? DateTime.fromMillisecondsSinceEpoch(message.date ?? 0).toLocal()
            : null;

        // Check for debit or credit keywords and extract amount
        if (debitKeywords.any((keyword) => body.contains(keyword.toLowerCase()))) {
          type = "Debited";
          debitAmount = _extractAmount(body);
        } else if (creditKeywords.any((keyword) => body.contains(keyword.toLowerCase()))) {
          type = "Credited";
          creditAmount = _extractAmount(body);
        }

        // Only include transactions matching type and amount
        if (type != null && (creditAmount != null || debitAmount != null)) {
          // Check month filter condition
          if (selectedMonth == -1 || // Show all transactions if "All" is selected
              (transactionDate != null &&
                  transactionDate.year == currentYear &&
                  transactionDate.month == selectedMonth)) {
            return {
              "type": type,
              "creditAmount": creditAmount,
              "debitAmount": debitAmount,
              "body": message.body ?? "",
              "date": transactionDate,
            };
          }
        }

        return null; // Skip messages that don't match criteria
      })
          .where((transaction) => transaction != null) // Remove null values
          .toList()
          .cast<Map<String, dynamic>>(); // Cast to list of maps
    });
  }

  double? _extractAmount(String body) {
    final amountRegex = RegExp(r'(?:rs\.?|inr)?\s?([0-9,]+(\.\d{1,2})?)', caseSensitive: false);
    final match = amountRegex.firstMatch(body);
    if (match != null) {
      String amountString = match.group(1)!.replaceAll(',', '');
      return double.tryParse(amountString);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final debitTransactions = _filteredTransactions.where((t) => t['type'] == 'Debited').toList();
    final creditTransactions = _filteredTransactions.where((t) => t['type'] == 'Credited').toList();
    return SafeArea(
      top: true,
      child: Scaffold(
        drawer: CustomDrawer(),
        appBar: AppBar(
          title: Text("Expense Tracker"),
          actions: [
            PopupMenuButton<int>(
              icon: Icon(Icons.settings),
              onSelected: (selectedMonth) {
                _getSmsPermissionAndListen(context);
                // _filterTransactions(selectedMonth);
              },
              itemBuilder: (context) {
                final months = [
                  "All", // Index 0 for "All"
                  "January",
                  "February",
                  "March",
                  "April",
                  "May",
                  "June",
                  "July",
                  "August",
                  "September",
                  "October",
                  "November",
                  "December"
                ];
                return List.generate(13, (index) {
                  return PopupMenuItem(
                    value: index == 0 ? -1 : index,
                    child: Text(months[index]),
                  );
                });
              },
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(icon: Icon(Icons.arrow_upward, color: Colors.red), text: "Debits"),
              Tab(icon: Icon(Icons.arrow_downward, color: Colors.green), text: "Credits"),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildTransactionList(debitTransactions, Colors.red, true),
            _buildTransactionList(creditTransactions, Colors.green, false),
          ],
        ),
      ),
    );
  }
  Widget _buildTransactionList(List<Map<String, dynamic>> transactions, Color iconColor, bool isTabIsDebit) {
    if (transactions.isEmpty) {
      return Center(child: Text("No transactions found for this month!"));
    }

    return RefreshIndicator(
      onRefresh: () async{
        _filterTransactions(DateTime.now().month);
        return ;
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15.0),
            margin: const EdgeInsets.all(5.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey, width: 0.5),
              borderRadius: BorderRadius.circular(5.0),
            ),
            child: Column(
              children: [
                Visibility(
                  visible: isTabIsDebit,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Total spent:"),
                      Text(
                        "\$ ${transactions.map((item) => item['debitAmount'] ?? 0.0).reduce((a, b) => a + b)}",
                      ),
                    ],
                  ),
                ),
                Visibility(
                  visible: !isTabIsDebit,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Total gain:"),
                      Text(
                        "\$ ${transactions.map((item) => item['creditAmount'] ?? 0.0).reduce((a, b) => a + b)}",
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final transaction = transactions[index];
                return Container(
                  margin: const EdgeInsets.all(5.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 0.0),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: ListTile(
                    leading: Icon(
                      transaction["type"] == "Debited" ? Icons.arrow_upward : Icons.arrow_downward,
                      color: iconColor,
                    ),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${transaction['type']} - \$${transaction[transaction['type'] == 'Debited' ? 'debitAmount' : 'creditAmount'].toStringAsFixed(2)}",
                          style: TextStyle(
                            color: iconColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          DateFormat("dd-MM-yyyy").format(transaction['date']),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    subtitle: Text(transaction["body"] ?? ""),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}