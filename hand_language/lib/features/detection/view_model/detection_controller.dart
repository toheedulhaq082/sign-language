import 'dart:async';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hand_language/features/ip/view_model/ip_controller.dart';
import 'package:http/http.dart' as http;

class DetectionController extends GetxController {
  var prediction = "Waiting for prediction...".obs;
  var isStreaming = false.obs;
  RxBool isCameraInitialized = false.obs;

  // Store detected characters and constructed sentence
  var detectedCharacters = <String>[].obs;
  final TextEditingController inputController = TextEditingController();
  final IPController ipController = Get.find();



  String? lastDetectedCharacter;



  Future<void> processImage(Uint8List jpegBytes) async {
    try {
      final response = await sendImageForPrediction(jpegBytes);
      handlePrediction(response['prediction']);
    } catch (e) {
      print('Error processing image: $e');
    }
  }

  void handlePrediction(String detectedCharacter){
    // Process detected character
    if (detectedCharacter == 'space') {
      // Handle space as a space character
      if (lastDetectedCharacter != 'space') {
        detectedCharacters.add(' ');
        inputController.text += " ";
      }
    } else if (detectedCharacter != "No hand detected") {
      if (detectedCharacter != lastDetectedCharacter) {
        detectedCharacters.add(detectedCharacter);
        lastDetectedCharacter = detectedCharacter;
        inputController.text += detectedCharacter;

      }
    }
  }

  Future<Map<String, dynamic>> sendImageForPrediction(Uint8List bytes) async {
    final url = Uri.parse("http://${ipController.ipAddress}:8000/detection/predict_frame/");
    final request = http.MultipartRequest('POST', url)
      ..files.add(http.MultipartFile.fromBytes('file', bytes, filename: 'frame.jpg'));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get prediction');
    }
  }

  Future<List<String>> fetchPredictions() async {
    print("hello");
    return await predictNextWords(inputController.text, 3);
  }

  Future<List<String>> predictNextWords(String inputText, int numSuggestions) async {
    final url = Uri.parse('http://${ipController.ipAddress}:8000/detection/predict-next-words/');  // Replace with your API URL
    try {
      // Create the request payload
      final body = jsonEncode({
        'input_text': inputText,
        'num_suggestions': numSuggestions,
      });

      // Make the POST request
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      // Check for successful response
      if (response.statusCode == 200) {
        // Decode the response
        final decodedResponse = jsonDecode(response.body);
        List<String> predictedWords = List<String>.from(decodedResponse['predicted_words']);

        return predictedWords;
      } else {
        throw Exception('Failed to generate predictions: ${response.body}');
      }
    } catch (e) {
      print("Error: $e");
      return [];
    }
  }

}
