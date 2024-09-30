import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:xoap/components/date_row.dart';
import 'chat_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';

class HomeScreen extends StatefulWidget {
  final User user;

  HomeScreen({required this.user});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _selectedDate = DateTime.now();
  FirebaseService _firebaseService = FirebaseService();
  List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadChatForSelectedDate();
  }

  // Load chat messages for the selected date
  void _loadChatForSelectedDate() async {
    List<Map<String, dynamic>> messages =
        await _firebaseService.getChat(widget.user.uid, _selectedDate);
    setState(() {
      _messages = messages;
    });
  }

  // Add a new message and save it to Firestore
  void _addMessage(String message) async {
    if (message.isNotEmpty) {
      setState(() {
        _messages.add({
          'message': message,
          'sentByUser': true,
          'timestamp': Timestamp.now()
        });
      });
      await _firebaseService.saveChat(
          widget.user.uid, _selectedDate, _messages);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          DateRow(
            selectedDate: _selectedDate,
            onDateSelected: (date) {
              setState(() {
                _selectedDate = date;
              });
              _loadChatForSelectedDate();
            },
          ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              onPressed: () {
                setState(() {
                  _selectedDate = DateTime.now();
                });
                _loadChatForSelectedDate();
              },
              child: const Tooltip(
                message: "Back to today's chat",
                child: Text(
                  'Today',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
          Expanded(
            // Pass selectedDate and messages to ChatScreen
            child: ChatScreen(
              user: widget.user,
              selectedDate: _selectedDate,
            ),
          ),
        ],
      ),
    );
  }
}
