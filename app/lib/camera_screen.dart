import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'detector.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  bool _isInitialized = false;
  bool _isProcessing = false;

  final Detector _detector = Detector();
  final FlutterTts _tts = FlutterTts();

  List<Detection> _detections = [];
  String _lastSpoken = '';
  DateTime _lastSpeakTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _detector.loadModel();
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.5);
    await _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    final back = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );

    _controller = CameraController(
      back,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    await _controller!.initialize();
    await _controller!.startImageStream(_onFrame);

    if (mounted) setState(() => _isInitialized = true);
  }

  void _onFrame(CameraImage image) async {
    if (_isProcessing) return;
    _isProcessing = true;

    final results = await _detector.detect(image);

    if (mounted) {
      setState(() => _detections = results);
    }

    if (results.isNotEmpty) {
      final now = DateTime.now();
      final topLabel = results.first.label;
      if (topLabel != _lastSpoken ||
          now.difference(_lastSpeakTime).inSeconds >= 3) {
        _lastSpoken = topLabel;
        _lastSpeakTime = now;
        await _tts.speak(topLabel);
      }
    }

    _isProcessing = false;
  }

  @override
  void dispose() {
    _controller?.stopImageStream();
    _controller?.dispose();
    _detector.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _controller == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          CameraPreview(_controller!),
          CustomPaint(painter: BoxPainter(_detections)),
          Positioned(
            bottom: 40,
            left: 16,
            right: 16,
            child: Column(
              children: _detections.take(3).map((d) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${d.label} — ${(d.confidence * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class BoxPainter extends CustomPainter {
  final List<Detection> detections;
  BoxPainter(this.detections);

  static const colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.cyan,
    Colors.yellow,
  ];

  static const labels = [
    'stairs',
    'door',
    'obstacle',
    'person',
    'pothole',
    'vehicle',
    'curb',
  ];

  @override
  void paint(Canvas canvas, Size size) {
    for (final det in detections) {
      final colorIndex = labels.indexOf(det.label) % colors.length;
      final color = colors[colorIndex];
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;

      final rect = Rect.fromLTWH(
        det.x * size.width,
        det.y * size.height,
        det.width * size.width,
        det.height * size.height,
      );

      canvas.drawRect(rect, paint);

      final textPainter = TextPainter(
        text: TextSpan(
          text: ' ${det.label} ${(det.confidence * 100).toStringAsFixed(0)}% ',
          style: TextStyle(
            color: Colors.white,
            fontSize: 13,
            backgroundColor: color,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(rect.left, rect.top - 18));
    }
  }

  @override
  bool shouldRepaint(BoxPainter old) => true;
}
