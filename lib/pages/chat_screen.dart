import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final Gemini gemini = Gemini.instance;

  List<ChatMessage> messages = []; // Final chat messages list
  List<ChatMessage> tempMessages = []; // Temporary messages storage

  ChatUser currentUser = ChatUser(id: "0", firstName: "User");
  ChatUser geminiUser = ChatUser(id: "1", firstName: "Xoap");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(child: _buildUI()), // Chat area
          // Feedback button
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
          contentPadding: EdgeInsets.all(15),
        ),
        alwaysShowSend: true,
        sendButtonBuilder: (void Function() sendMessage) {
          // Use sendButtonBuilder
          return Row(
            children: [
              Tooltip(
                message: "Send Message", // Hover text for the send button
                child: IconButton(
                  onPressed: sendMessage,
                  icon: const Icon(
                    Icons.send,
                    color: Colors.blue, // Change send button to blue
                  ),
                ),
              ),
              Tooltip(
                message: "Get Response", // Hover text for the send button
                child: IconButton(
                  onPressed: _sendFeedback,
                  icon: const Icon(
                    Icons.chat,
                    color: Colors.green, // Change send button to blue
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFeedbackButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        onPressed: _sendFeedback, // Trigger feedback
        child: const Text('Get Feedback'),
      ),
    );
  }

  void _sendMessage(ChatMessage chatMessage) {
    setState(() {
      tempMessages = [
        chatMessage,
        ...tempMessages
      ]; // Store in temp but still display
    });
  }

  void _sendFeedback() {
    // Move tempMessages to the final messages list
    setState(() {
      messages = [...tempMessages, ...messages];
      tempMessages.clear(); // Clear temp storage after feedback
    });

    try {
      // Process all messages sent by the user
      String conversation = messages.map((msg) => msg.text).join(" ");
      gemini.streamGenerateContent(conversation).listen((event) {
        String response = event.content?.parts?.fold(
                "", (previous, current) => "$previous ${current.text}") ??
            "";

        ChatMessage feedbackMessage = ChatMessage(
            user: geminiUser, createdAt: DateTime.now(), text: response);

        setState(() {
          messages = [
            feedbackMessage,
            ...messages
          ]; // Display Gemini's response
        });
      });
    } catch (e) {
      print(e);
    }
  }
}
