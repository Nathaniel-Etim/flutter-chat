import 'package:chat_app/widget/chat_messages.dart';
import 'package:chat_app/widget/new_message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  void setUpPushNotification() async {
    final fcm = FirebaseMessaging.instance;

    await fcm.requestPermission(alert: true, sound: true);

    // final token = await fcm.getToken();
    //print(token); //this will be sent to a backend using http

    fcm.subscribeToTopic('chat');
  }

  @override
  void initState() {
    super.initState();
    setUpPushNotification();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter Chat'), actions: [
        IconButton(
          onPressed: () {
            FirebaseAuth.instance.signOut();
          },
          icon: Icon(
            Icons.exit_to_app,
            color: Theme.of(context).colorScheme.primary,
          ),
        )
      ]),
      body: const Column(children: [
        Expanded(
          child: ChatMessages(),
        ),
        NewMessage(),
      ]),
    );
  }
}
