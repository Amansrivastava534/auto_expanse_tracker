import 'package:flutter/material.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';


class ExpenseTrackerPage extends StatefulWidget {
  @override
  _ExpenseTrackerPageState createState() => _ExpenseTrackerPageState();
}

class _ExpenseTrackerPageState extends State<ExpenseTrackerPage> with SingleTickerProviderStateMixin {
  final SmsQuery _smsQuery = SmsQuery();
  List<SmsMessage> _messages = [];
  List<Map<String, dynamic>> _filteredTransactions = [];
  late TabController _tabController;
  late StreamSubscription<List<SmsMessage>> _smsSubscription;
  final StreamController<List<SmsMessage>> _smsStreamController = StreamController.broadcast();

  @override
  void initState() {
    super.initState();
    _getSmsPermissionAndListen();
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

  Future<void> _getSmsPermissionAndListen() async {
    var status = await Permission.sms.status;
    if (status.isDenied) {
      status = await Permission.sms.request();
    }

    if (status.isGranted) {
      List<SmsMessage> newMessages = await _smsQuery.getAllSms;
      newMessages.sort((a, b) {
        // Use `compareTo` in reverse order to get descending sort
        return (b.date ?? DateTime.now()).compareTo(a.date ?? DateTime.now());
      });
      _smsStreamController.add(newMessages);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("SMS permission denied!")),
      );
    }
  }

  void _filterTransactions(int selectedMonth) {
    final now = DateTime.now();
    final currentYear = now.year;

    const accountNumbers = ["8378","3806"];
    const debitKeywords = ["Amt Sent","debited", "withdrawn", "Sent Rs."];
    const creditKeywords = ["credited to", "deposited","CREDITED to"];

    setState(() {
      _filteredTransactions = _messages.map((message) {
        final body = message.body?.toLowerCase() ?? "";
        String? type;
        double? creditAmount;
        double? debitAmount;

        final matchesAccount = accountNumbers.any((account) => body.contains(account.toLowerCase()));
        if (!matchesAccount) return null;

        if (debitKeywords.any((keyword) => body.contains(keyword.toLowerCase()))) {
          type = "Debited";
          debitAmount = _extractAmount(body);
        }
        if (creditKeywords.any((keyword) => body.contains(keyword.toLowerCase()))) {
          type = "Credited";
          creditAmount = _extractAmount(body);
        }

        if (type != null && (creditAmount != null || debitAmount != null)) {
          DateTime? transactionDate = message.date?.toLocal();
          if (selectedMonth == -1 || // Show all if "All" is selected
              (transactionDate != null &&
                  transactionDate.year == currentYear &&
                  transactionDate.month == selectedMonth)) {
            return {
              "sender": message.sender ?? "Unknown",
              "type": type,
              "creditAmount": creditAmount,
              "debitAmount": debitAmount,
              "body": message.body ?? "",
              "date": transactionDate,
            };
          }
        }
        return null;
      }).where((transaction) => transaction != null).toList().cast<Map<String, dynamic>>();
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
        drawer: Drawer(
          width: 220,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20,10,0,0),
            child: ListView(
              shrinkWrap: true,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                      icon: Icon(
                        Icons.close,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(context);
                      }),
                ),
                InkWell(
                  child: Row(
                    children: [
                      Icon(Icons.settings),
                      SizedBox(width: 10,),
                      Text("Settings")
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
        appBar: AppBar(
          title: Text("Expense Tracker"),
          actions: [
            PopupMenuButton<int>(
              icon: Icon(Icons.settings),
              onSelected: (selectedMonth) {
                _filterTransactions(selectedMonth);
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
                          "${transaction['type']} - \$${transaction[transaction['type'] == 'Debited' ? 'debitAmount' : 'creditAmount']!.toStringAsFixed(2)}",
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