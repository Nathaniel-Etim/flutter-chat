import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

class AuthenticateUserLogin extends GetxController {
  var loadingSpinner = false.obs;
  var errorMessage = ''.obs;
  var hasError = false.obs;

  bool get getLoadingSpinner => loadingSpinner.value;

  String get getErrorMessage => errorMessage.value;

  bool get getHasError => hasError.value;

  Future<void> fireBaseAuthentication(
      String link, String password, String email) async {
    loadingSpinner.value = true;
    hasError.value = false;
    try {
      final Map<String, dynamic> requestBody = {
        'email': email,
        'password': password,
        'returnSecureToken': true, // Set this to true to obtain a secure token.
      };
      final response = await http.post(
        Uri.parse(link),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Request was successful
        final responseData = jsonDecode(response.body);
        print(responseData['idToken']);
        final secureToken = responseData['idToken'];
        return secureToken;
      } else {
        // Request failed
        loadingSpinner.value = false;
        hasError.value = false;
        errorMessage.value =
        'request failed error ${response.statusCode} pls try registering ';
      }
    } catch (error) {
      hasError.value = true;
      errorMessage.value = 'Error : Check internet connection';
    } finally {
      loadingSpinner.value = false;
    }
  }
}
