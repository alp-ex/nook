import 'package:flutter/material.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    final chats = [
      'Conversation with San Francisco',
      'Conversation with Los Angeles',
      'Conversation with New York',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
      ),
      body: ListView.builder(
        itemCount: chats.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(chats[index]),
            onTap: () {
              // Navigate to chat detail page (not implemented)
            },
          );
        },
      ),
    );
  }
}
