import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderID;
  final String senderEmail;
  final String receiverID;
  final String message;
  final Timestamp timestamp;

  Message({
    required this.senderEmail,
    required this.senderID,
    required this.receiverID,
    required this.message,
    required this.timestamp,
  });
  //convert to map
  Map<String, dynamic> toMap() {
    return {
      'senderId': senderID,
      'senderEmail': senderEmail,
      'receiverEmail': receiverID,
      'message': message,
      'timestamp': timestamp
    };
  }
}
