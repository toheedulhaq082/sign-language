import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hand_language/features/auth/view/login_screen.dart';
import 'package:hand_language/features/auth/view_model/auth_controller.dart';
import 'package:hand_language/features/detection/view/detection_screen.dart';
import 'package:hand_language/features/ip/view_model/ip_controller.dart';

void main() async{
  Get.put(IPController());
  final AuthController authController = Get.put(AuthController());
  await authController.loadUserFromStorage();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  final AuthController authController = Get.find();

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Syncsense',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home:  authController.user.value == null ? const LoginScreen() : const DetectionScreen(),
    );
  }
}