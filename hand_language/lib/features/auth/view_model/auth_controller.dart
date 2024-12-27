import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:hand_language/features/auth/view/login_screen.dart';
import 'package:hand_language/features/detection/view/detection_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../ip/view_model/ip_controller.dart';
import '../model/user_model.dart';

class AuthController extends GetxController {
  Rx<User?> user = Rxn<User>();

  final String userIdKey = 'user_id';

  final IPController ipController = Get.find();



  // Sign Up function
  Future<void> signUp(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('http://${ipController.ipAddress}:8000/auth/signup/'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        // Create User object
        var newUser = User(
          email: email,
          userId: data['user_id'],
        );
        user.value = newUser;
        await _saveUserIdToStorage(newUser.userId);
        Fluttertoast.showToast(msg: "Signed up successfully.",backgroundColor: Colors.green);
        Get.offAll(()=> const DetectionScreen());

      } else {
        var data = jsonDecode(response.body);
        Fluttertoast.showToast(msg: data["detail"],backgroundColor: Colors.red);
      }
    } catch (e) {
      print(e);
      Fluttertoast.showToast(msg: "Unexpected error occurred",backgroundColor: Colors.red);
    }
  }

  // Sign In function
  Future<void> signIn(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('http://${ipController.ipAddress}:8000/auth/signin/'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        // Create User object
        var signedInUser = User(
          email: data['email'],
          userId: data['user_id'],
        );
        user.value = signedInUser;
        await _saveUserIdToStorage(signedInUser.userId);
        Fluttertoast.showToast(msg: "Signed in successfully.",backgroundColor: Colors.green);
        Get.offAll(()=> const DetectionScreen());

      } else {
        var data = jsonDecode(response.body);
        Fluttertoast.showToast(msg: data["detail"],backgroundColor: Colors.red);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Unexpected error occurred",backgroundColor: Colors.red);
    }
  }

  // Log out function
  Future<void> logout() async {
    user.value = null;
    await _removeUserIdFromStorage();
    Get.offAll(() => const LoginScreen());
  }

  // Save userId to SharedPreferences
  Future<void> _saveUserIdToStorage(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(userIdKey, userId);
  }

  // Remove userId from SharedPreferences
  Future<void> _removeUserIdFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(userIdKey);
  }

  // Load userId from SharedPreferences and set it in user object
  Future<void> loadUserFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    int? savedUserId = prefs.getInt(userIdKey);
    if (savedUserId != null) {
      user.value = User(
        email: "Placeholder@example.com",
        userId: savedUserId,
      );
    }
  }
}