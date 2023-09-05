import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({super.key});

  @override
  State<NewMessage> createState() {
    return _NewMessageState();
  }
}

class _NewMessageState extends State<NewMessage> {
  final _formField = GlobalKey<FormState>();
  var messageInput;

  @override
  Widget build(BuildContext context) {
    void _submitMessage() async {
      if (!_formField.currentState!.validate()) {
        return;
      }
      _formField.currentState!.save();

      FocusScope.of(context).unfocus();
      _formField.currentState!.reset();

      final user = FirebaseAuth.instance.currentUser!;
      final userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      FirebaseFirestore.instance.collection('chat').add({
        'text': messageInput,
        'createAt': Timestamp.now(),
        'userId': user.uid,
        'username': userData.data()!['userName'],
        'userImage': userData.data()!['image_url'],
      });
    }

    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 1, bottom: 14),
      child: Row(children: [
        Expanded(
          child: Form(
            key: _formField,
            child: TextFormField(
              decoration: const InputDecoration(
                label: Text("Sends Message..."),
              ),
              autocorrect: true,
              enableSuggestions: true,
              textCapitalization: TextCapitalization.sentences,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Can\'t sent an empty space";
                }
                return null;
              },
              onSaved: (newValue) => messageInput = newValue,
            ),
          ),
        ),
        IconButton(
          color: Theme.of(context).colorScheme.primary,
          onPressed: _submitMessage,
          icon: const Icon(Icons.send),
        )
      ]),
    );
  }
}
