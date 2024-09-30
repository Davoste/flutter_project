import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

class ChatScreen extends StatefulWidget {
  final DateTime selectedDate;
  final User user; // Pass the current logged-in user

  const ChatScreen({
    Key? key,
    required this.selectedDate,
    required this.user,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final Gemini gemini = Gemini.instance;
  List<ChatMessage> messages = []; // Final chat messages list
  List<ChatMessage> tempMessages = []; // Temporary messages storage

  ChatUser currentUser = ChatUser(id: "0", firstName: "User");
  ChatUser geminiUser = ChatUser(id: "1", firstName: "XOAP", profileImage: '');

  @override
  void initState() {
    super.initState();
    _loadSavedMessages(); // Load chat history from Firestore when the screen is initialized
  }

  // Load messages from Firestore for the selected date
  void _loadSavedMessages() async {
    final String userId = widget.user.uid;

    // Firestore reference for the user's chat room and messages collection
    CollectionReference messagesCollection = FirebaseFirestore.instance
        .collection('chat_rooms')
        .doc(userId)
        .collection('messages');

    // Query messages stored for the current user
    QuerySnapshot querySnapshot = await messagesCollection.get();

    // Map the fetched Firestore documents to ChatMessage objects
    List<ChatMessage> fetchedMessages = querySnapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return ChatMessage(
        user: data['user'] == 'Gemini'
            ? geminiUser
            : ChatUser(id: widget.user.uid),
        createdAt: DateTime.parse(data['createdAt']),
        text: data['text'],
      );
    }).toList();

    setState(() {
      messages = fetchedMessages.reversed.toList(); // Display most recent first
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(child: _buildUI()), // Chat area
        ],
      ),
    );
  }

  Widget _buildUI() {
    // Combine tempMessages with the final messages for display
    List<ChatMessage> displayMessages = [...tempMessages, ...messages];

    return DashChat(
      currentUser: currentUser,
      onSend: _sendMessage,
      messages: displayMessages, // Display both temp and final messages
      messageOptions: const MessageOptions(
        currentUserContainerColor:
            Colors.blueAccent, // Customize current user's bubble
      ),
      inputOptions: InputOptions(
        inputDecoration: InputDecoration(
          hintText: "Talk to me...",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.all(15),
        ),
        alwaysShowSend: true,
        sendButtonBuilder: (void Function() sendMessage) {
          return Row(
            children: [
              Tooltip(
                message: "Write notes", // Hover text for the send button
                child: IconButton(
                  onPressed: sendMessage,
                  icon: const Icon(
                    Icons.mode_edit_sharp,
                    color: Colors.blue, // Change send button to blue
                  ),
                ),
              ),
              Tooltip(
                message: "Get Response", // Hover text for the send button
                child: IconButton(
                  onPressed: _sendFeedback,
                  icon: const Icon(
                    Icons.send_sharp,
                    color: Colors.green, // Change send button to green
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // This function handles sending the user's message and storing it in Firestore.
  void _sendMessage(ChatMessage chatMessage) async {
    final String userId = widget.user.uid;

    // Firestore reference for the user's chat room and messages collection
    CollectionReference messagesCollection = FirebaseFirestore.instance
        .collection('chat_rooms')
        .doc(userId)
        .collection('messages');

    try {
      // Save the user message in Firestore
      await messagesCollection.add({
        'user': currentUser.firstName ?? "User", // User's name
        'text': chatMessage.text,
        'createdAt': chatMessage.createdAt.toIso8601String(),
      });

      // Add the message to the tempMessages list for displaying
      setState(() {
        tempMessages = [
          chatMessage,
          ...tempMessages,
        ]; // Add to tempMessages to display immediately
      });

      // Refresh the message list from Firestore after saving
      _loadSavedMessages();
    } catch (e) {
      print("Error sending message to Firestore: $e"); // Log any errors
    }
  }

  // This function handles getting a response from Gemini and saving it to Firestore.
  void _sendFeedback() async {
    final User? firebaseUser = FirebaseAuth.instance.currentUser;

    if (firebaseUser == null) {
      print("No user logged in");
      return;
    }

    final String userId = firebaseUser.uid;

    // Firestore reference for the user's chat room
    CollectionReference messagesCollection = FirebaseFirestore.instance
        .collection('chat_rooms')
        .doc(userId)
        .collection('messages');

    // Move tempMessages to the final messages list
    setState(() {
      messages = [...tempMessages, ...messages];
      tempMessages.clear(); // Clear temp storage after feedback
    });

    // Add a "typing..." message to the list
    ChatMessage typingMessage = ChatMessage(
      user: geminiUser, // Ensure this user has a valid name/firstName
      createdAt: DateTime.now(),
      text: "XOAP is replying to you...",
    );

    // Insert "typing..." message into Firestore under the current user's chat room
    await messagesCollection.add({
      'user': geminiUser.firstName ??
          "Gemini", // Use firstName or appropriate field
      'text': typingMessage.text,
      'createdAt': typingMessage.createdAt.toIso8601String(),
    });

    setState(() {
      messages.insert(0, typingMessage); // Display typing indicator
    });

    try {
      // Concatenate the text of all user messages
      String conversation = messages.map((msg) => msg.text).join(" ");

      // Process AI response
      gemini.streamGenerateContent(conversation).listen((event) async {
        String response = event.content?.parts?.fold(
                "", (previous, current) => "$previous ${current.text}") ??
            "";

        // Remove the "typing..." message before adding the actual response
        setState(() {
          messages.remove(typingMessage);
        });

        // Add the actual AI response
        ChatMessage feedbackMessage = ChatMessage(
          user: geminiUser, // Ensure this uses a valid field for the name
          createdAt: DateTime.now(),
          text: response,
        );

        // Store the response in Firestore under the current user's chat room
        await messagesCollection.add({
          'user': feedbackMessage.user.firstName ?? "Gemini",
          'text': feedbackMessage.text,
          'createdAt': feedbackMessage.createdAt.toIso8601String(),
        });

        // Update UI with Gemini's response
        setState(() {
          messages.insert(0, feedbackMessage); // Insert at the top of the list
        });
      });
    } catch (e) {
      // Remove the "typing..." message if there's an error
      setState(() {
        messages.remove(typingMessage);
      });
      print("Error processing feedback: $e");
    }
  }
}
