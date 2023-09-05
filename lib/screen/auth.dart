import 'dart:io';

import 'package:chat_app/controllers/user_auth_controller.dart';
import 'package:chat_app/widget/user_image_pricker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final formKey = GlobalKey<FormState>();
  AuthenticateUserLogin auth = Get.put(
    AuthenticateUserLogin(),
  );

  var _isLogin = true;
  late String url;
  var isAuthenticating = false;
  late String emailInput;
  late String usernameInput;
  late String passwordInput;
  File? _selectedImage;

  @override
  Widget build(BuildContext context) {
    void submit() async {
      final isValid = formKey.currentState!.validate();
      if (!isValid || !_isLogin && _selectedImage == null) {
        // show error message
        return;
      }

      formKey.currentState!.save();
      try {
        setState(() {
          isAuthenticating = true;
        });
        if (_isLogin) {
          //   log users in
          await _firebase.signInWithEmailAndPassword(
            email: emailInput,
            password: passwordInput,
          );
        } else {
          // sign user in
          final userCredentials =
              await _firebase.createUserWithEmailAndPassword(
            email: emailInput,
            password: passwordInput,
          );
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('user_images')
              .child('${userCredentials.user!.uid}.jpg');

          await storageRef.putFile(_selectedImage!);
          final imageUrl = await storageRef.getDownloadURL();

          await FirebaseFirestore.instance
              .collection('users')
              .doc(userCredentials.user!.uid)
              .set({
            'userName': usernameInput,
            'email': emailInput,
            'image_url': imageUrl,
          });
        }
      } on FirebaseAuthException catch (error) {
        if (error.code == 'email-already-in-use') {
          //   you can throw error message on screen
        }
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error.message ?? 'Authentication failed',
            ),
          ),
        );
        setState(() {
          isAuthenticating = false;
        });
      }
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(
                  top: 30,
                  bottom: 20,
                  left: 20,
                  right: 20,
                ),
                width: 200,
                child: Image.asset(
                  'assets/images/chat.png',
                ),
              ),
              Card(
                margin: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!_isLogin)
                            UserImagePicker(onPickImage: (pickedImage) {
                              _selectedImage = pickedImage;
                            }),
                          TextFormField(
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              label: Text('Email Address'),
                            ),
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty ||
                                  !value.contains('@')) {
                                return "Please enter a valid email";
                              }
                              return null;
                            },
                            onSaved: (newValue) {
                              emailInput = newValue!;
                            },
                          ),
                          if (!_isLogin)
                            TextFormField(
                              keyboardType: TextInputType.emailAddress,
                              enableSuggestions: false,
                              decoration: const InputDecoration(
                                label: Text('Username'),
                              ),
                              autocorrect: false,
                              textCapitalization: TextCapitalization.characters,
                              validator: (value) {
                                if (value == null ||
                                    value.trim().isEmpty ||
                                    value.length < 4) {
                                  return "Please enter at least 4 characters";
                                }
                                return null;
                              },
                              onSaved: (newValue) {
                                usernameInput = newValue!;
                              },
                            ),
                          TextFormField(
                            // keyboardType: TextInputType.visiblePassword,
                            decoration: const InputDecoration(
                              label: Text('Password'),
                            ),
                            autocorrect: false,
                            obscureText: true,
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty ||
                                  value.trim().length < 6) {
                                return "enter at least 6 character long password";
                              }
                              return null;
                            },
                            onSaved: (newValue) =>
                                passwordInput = newValue as String,
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          if (isAuthenticating)
                            const CircularProgressIndicator(),
                          if (!isAuthenticating)
                            ElevatedButton(
                              onPressed: submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                              ),
                              child: Text(_isLogin ? 'Login' : 'Signup'),
                            ),
                          if (!isAuthenticating)
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _isLogin = !_isLogin;
                                });
                              },
                              child: Text(
                                _isLogin
                                    ? 'Create an account'
                                    : 'Have an account? Login',
                              ),
                            ),
                          Obx(
                            () => Visibility(
                              visible: auth.getHasError,
                              child: Container(
                                alignment: Alignment.center,
                                margin: const EdgeInsets.all(10),
                                width: double.infinity,
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(20),
                                  ),
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onErrorContainer,
                                ),
                                child: Text(
                                  auth.getErrorMessage,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
