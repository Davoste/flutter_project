import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderEmail;
  final String senderID;
  final String receiverID;
  final String message;
  final Timestamp timestamp;
  final String date; // New field for date

  Message({
    required this.senderEmail,
    required this.senderID,
    required this.receiverID,
    required this.message,
    required this.timestamp,
    required this.date, // Constructor includes date
  });

  // Convert Message to a Map
  Map<String, dynamic> toMap() {
    return {
      'senderEmail': senderEmail,
      'senderID': senderID,
      'receiverID': receiverID,
      'message': message,
      'timestamp': timestamp,
      'date': date, // Include date in the Map
    };
  }

  // Create Message from a Map
  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      senderEmail: map['senderEmail'],
      senderID: map['senderID'],
      receiverID: map['receiverID'],
      message: map['message'],
      timestamp: map['timestamp'],
      date: map['date'], // Extract date from the Map
    );
  }
}
