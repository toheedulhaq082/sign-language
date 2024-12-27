import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:hand_language/features/auth/view_model/auth_controller.dart';
import '../view_model/detection_controller.dart';
import 'package:camerawesome/camerawesome_plugin.dart';


class DetectionScreen extends StatefulWidget {
  const DetectionScreen({super.key});

  @override
  State<DetectionScreen> createState() => _DetectionScreenState();
}



class _DetectionScreenState extends State<DetectionScreen> {
  final DetectionController detectionController = Get.put(DetectionController());
  final AuthController authController = Get.find();



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Signsense'),
        actions: [
          IconButton(
            onPressed: () {
              authController.logout();
            },
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: CameraAwesomeBuilder.previewOnly(
              previewFit: CameraPreviewFit.contain,
              sensorConfig: SensorConfig.single(
                sensor: Sensor.position(SensorPosition.front),
                aspectRatio: CameraAspectRatios.ratio_1_1,
              ),
              onImageForAnalysis: (AnalysisImage img) async {
                img.when(
                  jpeg: (JpegImage image) {
                    detectionController.processImage(image.bytes);
                  },
                );
              },
              imageAnalysisConfig: AnalysisConfig(
                autoStart: false,
                androidOptions: const AndroidAnalysisOptions.jpeg(
                  width: 250,
                ),
                maxFramesPerSecond: 1,
              ),
              builder: (state, preview) {
                return Column(
                  children: [
                    const SizedBox(height: 10),
                    Container(
                      constraints: const BoxConstraints(maxHeight: 200),
                      margin: const EdgeInsets.all(20),
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: TypeAheadField<String>(
                        controller: detectionController.inputController,
                        builder: (context, controller, focusNode) {

                          return TextField(

                            minLines: 1,
                              maxLines: 3,
                              controller: detectionController.inputController,
                              focusNode: focusNode,
                              autofocus: true,
                              readOnly: true,
                              showCursor: true,
                              decoration: const InputDecoration(

                                border: OutlineInputBorder(),
                                labelText: 'prediction',
                                hintText: 'waiting for prediction...'
                              )
                          );
                        },

                        suggestionsCallback: (pattern) async {
                          return await detectionController.fetchPredictions();
                        },
                        itemBuilder: (context, suggestion) {
                          return ListTile(
                            title: Text(suggestion),
                          );
                        },
                        onSelected: (suggestion) {
                          detectionController.inputController.text += " $suggestion";
                        },
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {
                        if (state.analysisController?.enabled) {
                          detectionController.isStreaming.value = false;
                          state.analysisController?.stop();
                        } else {
                          detectionController.isStreaming.value = true;
                          detectionController.inputController.text = "";
                          state.analysisController?.start();
                        }
                      },
                      icon: Obx(() => Icon(
                        detectionController.isStreaming.value ? Icons.stop_circle_outlined : Icons.fiber_manual_record,
                        size: 100,
                        color: detectionController.isStreaming.value ? Colors.red : Colors.white,
                      )),
                    ),
                  ],
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
