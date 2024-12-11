import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../components/customSaveButton.dart';
import '../components/customScaffold.dart';
import '../constants.dart';
import '../utils.dart';
import 'expanseTrackerPage.dart';

class CardSaverPage extends StatefulWidget {
  @override
  _CardSaverPageState createState() => _CardSaverPageState();
}

class _CardSaverPageState extends State<CardSaverPage> {
  final TextEditingController _cardNumberController = TextEditingController();
  List<String> _cards = [];

  @override
  void initState() {
    super.initState();
    _loadSavedCards();
  }

  Future<void> _saveCard() async {
    String cardNumber = _cardNumberController.text.trim();

    if (cardNumber.isNotEmpty && cardNumber.length == 4) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        _cards.add(cardNumber); // Save only last 4 digits
        _cardNumberController.clear(); // Clear input field
      });

      // Save the updated list to SharedPreferences
      await prefs.setStringList('savedCards', _cards);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter exactly the last 4 digits of the card!')),
      );
    }
  }

  Future<void> _loadSavedCards() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedCards = prefs.getStringList('savedCards');

    if (savedCards != null) {
      setState(() {
        _cards = savedCards;
      });
    }
  }

  Future<void> _deleteCard(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _cards.removeAt(index);
    });

    // Update the stored list after deleting
    await prefs.setStringList('savedCards', _cards);
  }

  Widget _buildCardList() {
    if (_cards.isEmpty) {
      return const Center(
        child: Text(
          'No cards added yet!',
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: _cards.length,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 5),
          child: ListTile(
            enabled: true,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              side: const BorderSide(width: 2)
            ),
            title: Text(
              'Card last digit ${_cards[index]}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteCard(index),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title:"Manage Cards",
      drawerDisable: _cards.isEmpty,
      appBarActions: [
        GradientButton(
          onPressed: () async{
            if(_cards.isNotEmpty) {
              navigateAndRemoveUntilPage(const ExpenseTrackerPage(),context);
            }else{
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please save at least 1 card')),
              );
            }

          } ,
          label: "SAVE",
        )
      ],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: Container(
                color: Colors.grey.shade100,
                child: Column(
                  children: [
                    Container(
                        padding: const EdgeInsets.all(5.0),
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color:Colors.blueAccent.shade400, width: 0.9),
                          borderRadius: BorderRadius.circular(borderRadius),
                        ),
                      child: const Row(
                        children: [
                          Icon(Icons.info,color: Colors.blueAccent,),
                          Expanded(child: Text("Provide the last 4 digits of your card to filter bank messages. Multiple cards are supported.")),
                        ],
                      )),
                    TextField(
                      controller: _cardNumberController,
                      maxLength: 4,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Enter Last 4 Digits of Card',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 5),
                    GradientButton(
                      onPressed: _saveCard ,
                      label: "ADD CARD",
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            Flexible(
              flex: 5,
                child: _buildCardList()),
          ],
        ),
      ),
    );
  }
}