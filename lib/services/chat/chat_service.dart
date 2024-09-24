import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:xoap/models/message.dart';

class ChatService {
  //get instance of firestore and auth
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //get  user  stream
  Stream<List<Map<String, dynamic>>> getUserStreamSream() {
    return _firestore.collection("Users").snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        //go thhrough each individual user
        final user = doc.data();
        //return user
        return user;
      }).toList();
    });
  }

  //send message
  Future<void> sendMessage(String receiverID, message) async {
    //get curent user info
    final String currentUserId = _auth.currentUser!.uid;
    final String currentUserEmail = _auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();
    //create a meassage
    Message newMessage = Message(
      senderEmail: currentUserEmail,
      senderID: currentUserId,
      receiverID: receiverID,
      message: message,
      timestamp: timestamp,
    );

    //construct chat room id
    List<String> ids = [currentUserId, receiverID];
    ids.sort(); // sort id ensure every chatroomID is the same for 3 pple
    String chatRoomID = ids.join('_');
    //add message to db
    await _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .add(newMessage.toMap());
  }

  //get message
  Stream<QuerySnapshot> getMessages(String userID, otherUserID) {
    List<String> ids = [userID, otherUserID];
    ids.sort();
    String ChatRoomID = ids.join('_');

    return _firestore
        .collection("chat_rooms")
        .doc(ChatRoomID)
        .collection("messages")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }
}
