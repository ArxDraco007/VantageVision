import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:camera/camera.dart';
import 'dart:typed_data';

class Detection {
  final String label;
  final double confidence;
  final double x, y, width, height;

  Detection({
    required this.label,
    required this.confidence,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });
}

class Detector {
  Interpreter? _interpreter;
  bool _isLoaded = false;

  static const List<String> labels = [
    'stairs',
    'door',
    'obstacle',
    'person',
    'pothole',
    'vehicle',
    'curb',
  ];

  static const int inputSize = 640;
  static const double confidenceThreshold = 0.4;
  static const double iouThreshold = 0.5;

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/vantage.tflite');
      _isLoaded = true;
      print('✅ Model loaded!');
    } catch (e) {
      print('❌ Error loading model: $e');
    }
  }

  img.Image _convertYUV420toRGB(CameraImage cameraImage) {
    final int width = cameraImage.width;
    final int height = cameraImage.height;
    final img.Image image = img.Image(width: width, height: height);

    final yBytes = cameraImage.planes[0].bytes;
    final uBytes = cameraImage.planes[1].bytes;
    final vBytes = cameraImage.planes[2].bytes;

    final uvRowStride = cameraImage.planes[1].bytesPerRow;
    final uvPixelStride = cameraImage.planes[1].bytesPerPixel!;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final uvIndex = uvPixelStride * (x ~/ 2) + uvRowStride * (y ~/ 2);
        final index = y * width + x;

        final yVal = yBytes[index];
        final uVal = uBytes[uvIndex];
        final vVal = vBytes[uvIndex];

        int r = (yVal + (1.370705 * (vVal - 128))).round().clamp(0, 255);
        int g = (yVal - (0.337633 * (uVal - 128)) - (0.698001 * (vVal - 128)))
            .round()
            .clamp(0, 255);
        int b = (yVal + (1.732446 * (uVal - 128))).round().clamp(0, 255);

        image.setPixelRgb(x, y, r, g, b);
      }
    }
    return image;
  }

  Float32List _preprocessImage(img.Image image) {
    final resized = img.copyResize(image, width: inputSize, height: inputSize);
    final input = Float32List(1 * inputSize * inputSize * 3);

    int i = 0;
    for (int y = 0; y < inputSize; y++) {
      for (int x = 0; x < inputSize; x++) {
        final pixel = resized.getPixel(x, y);
        input[i++] = pixel.r / 255.0;
        input[i++] = pixel.g / 255.0;
        input[i++] = pixel.b / 255.0;
      }
    }
    return input;
  }

  List<Detection> _applyNMS(List<Detection> detections) {
    detections.sort((a, b) => b.confidence.compareTo(a.confidence));
    final result = <Detection>[];
    for (final det in detections) {
      bool keep = true;
      for (final kept in result) {
        if (_iou(det, kept) > iouThreshold) {
          keep = false;
          break;
        }
      }
      if (keep) result.add(det);
    }
    return result;
  }

  double _iou(Detection a, Detection b) {
    final ax1 = a.x, ay1 = a.y, ax2 = a.x + a.width, ay2 = a.y + a.height;
    final bx1 = b.x, by1 = b.y, bx2 = b.x + b.width, by2 = b.y + b.height;

    final interX1 = ax1 > bx1 ? ax1 : bx1;
    final interY1 = ay1 > by1 ? ay1 : by1;
    final interX2 = ax2 < bx2 ? ax2 : bx2;
    final interY2 = ay2 < by2 ? ay2 : by2;

    final interArea =
        (interX2 - interX1).clamp(0, double.infinity) *
        (interY2 - interY1).clamp(0, double.infinity);
    final aArea = a.width * a.height;
    final bArea = b.width * b.height;

    return interArea / (aArea + bArea - interArea);
  }

  Future<List<Detection>> detect(CameraImage cameraImage) async {
    if (!_isLoaded || _interpreter == null) return [];

    try {
      final rgbImage = _convertYUV420toRGB(cameraImage);
      final input = _preprocessImage(rgbImage);
      final inputTensor = input.reshape([1, inputSize, inputSize, 3]);

      final outputTensor = List.generate(
        1,
        (_) => List.generate(11, (_) => List.filled(8400, 0.0)),
      );

      _interpreter!.runForMultipleInputs([inputTensor], {0: outputTensor});

      final detections = <Detection>[];
      final output = outputTensor[0];

      for (int i = 0; i < 8400; i++) {
        final cx = output[0][i];
        final cy = output[1][i];
        final w = output[2][i];
        final h = output[3][i];

        double maxConf = 0.0;
        int bestClass = 0;
        for (int c = 0; c < labels.length; c++) {
          final conf = output[4 + c][i];
          if (conf > maxConf) {
            maxConf = conf;
            bestClass = c;
          }
        }

        if (maxConf >= confidenceThreshold) {
          detections.add(
            Detection(
              label: labels[bestClass],
              confidence: maxConf,
              x: (cx - w / 2) / inputSize,
              y: (cy - h / 2) / inputSize,
              width: w / inputSize,
              height: h / inputSize,
            ),
          );
        }
      }

      return _applyNMS(detections);
    } catch (e) {
      print('❌ Detection error: $e');
      return [];
    }
  }

  void dispose() {
    _interpreter?.close();
  }
}
