import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Fetch chat messages for a specific user and date
  Future<List<Map<String, dynamic>>> getChat(
      String userId, DateTime date) async {
    try {
      String formattedDate = "${date.year}-${date.month}-${date.day}";

      DocumentSnapshot doc = await _firestore
          .collection('Chats')
          .doc(userId)
          .collection('Messages')
          .doc(formattedDate)
          .get();

      if (doc.exists) {
        List<Map<String, dynamic>> messages =
            List<Map<String, dynamic>>.from(doc['messages']);
        return messages;
      } else {
        return [];
      }
    } catch (e) {
      throw Exception("Error fetching chat messages: $e");
    }
  }

  // Save chat messages for a specific user and date
  Future<void> saveChat(
      String userId, DateTime date, List<Map<String, dynamic>> messages) async {
    try {
      String formattedDate = "${date.year}-${date.month}-${date.day}";

      await _firestore
          .collection('Chats')
          .doc(userId)
          .collection('Messages')
          .doc(formattedDate)
          .set({'messages': messages});
    } catch (e) {
      throw Exception("Error saving chat messages: $e");
    }
  }

  // Sign out the user
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
