import 'dart:async';
import 'dart:html' as html;
import 'dart:js' as js;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';
import 'package:autour_web/utils/colors.dart';
import 'package:autour_web/utils/js_interop.dart';
import 'package:autour_web/widgets/text_widget.dart';
import 'package:autour_web/widgets/button_widget.dart';

class PeopleCountingScreen extends StatefulWidget {
  const PeopleCountingScreen({super.key});

  @override
  State<PeopleCountingScreen> createState() => _PeopleCountingScreenState();
}

class _PeopleCountingScreenState extends State<PeopleCountingScreen> {
  html.VideoElement? _videoElement;
  int _peopleCount = 0;
  bool _isCameraActive = false;
  Timer? _detectionTimer;
  final String _videoElementId = 'webcam-video';

  @override
  void initState() {
    super.initState();
    // Don't automatically start the camera, wait for user to click "Start Camera"
    // Preload the TensorFlow.js model
    _loadModel();
    // Register the view factory in advance
    _registerViewFactory();

    // Create the video element immediately
    _createVideoElement();
  }

  void _createVideoElement() {
    // Create a video element that we'll use
    _videoElement = html.VideoElement()
      ..id = _videoElementId
      ..autoplay = true
      ..muted = true
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.objectFit = 'cover'
      ..style.display = 'none'; // Hide it initially

    // Add it to the DOM for JavaScript access
    html.document.body?.append(_videoElement!);

    print('Video element created and added to DOM');
  }

  void _registerViewFactory() {
    // Register the view factory to return our video element
    ui_web.platformViewRegistry.registerViewFactory(
      _videoElementId,
      (int viewId) {
        // Make sure the video element is visible when used in the view
        if (_videoElement != null) {
          _videoElement!.style.display = 'block';
        }
        return _videoElement!;
      },
    );
  }

  Future<void> _loadModel() async {
    try {
      // Call JavaScript function to load the model via JsInterop
      await js.context.callMethod('loadModel', []);
      print('Model loading initiated');
    } catch (e) {
      print('Error loading model: $e');
    }
  }

  @override
  void dispose() {
    _detectionTimer?.cancel();
    _stopCamera();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      // Force a rebuild to show the video element
      setState(() {
        _isCameraActive = false;
      });

      // Wait for the next frame to ensure the video element is created
      await Future.delayed(const Duration(milliseconds: 100));

      // Check if video element exists
      if (_videoElement == null) {
        print('Video element is null, creating a new one');
        _createVideoElement();
      }

      // Get camera stream
      final stream = await html.window.navigator.mediaDevices?.getUserMedia({
        'video': {'facingMode': 'user'}
      });

      if (stream != null && _videoElement != null) {
        print('Camera stream obtained successfully');
        _videoElement!.srcObject = stream;
        print('Video srcObject set to: ${_videoElement!.srcObject}');

        // Wait for the video to be ready
        _videoElement!.onLoadedMetadata.listen((_) {
          print('Video metadata loaded');
          print('Video ready state: ${_videoElement!.readyState}');
          print(
              'Video dimensions: ${_videoElement!.videoWidth}x${_videoElement!.videoHeight}');

          // Wait a bit more to ensure the video is fully ready
          Future.delayed(const Duration(milliseconds: 1000), () {
            // Check if video is playing
            if (_videoElement!.paused || _videoElement!.ended) {
              print('Video is paused or ended, attempting to play');
              _videoElement!.play().catchError((e) {
                print('Error playing video: $e');
              });
            }

            setState(() {
              _isCameraActive = true;
            });

            // Start people detection timer
            _startPeopleDetection();
          });
        });
      } else {
        print('Failed to get camera stream or video element is null');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to access camera'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error initializing camera: $e');
      print('Stack trace: ${StackTrace.current}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error accessing camera: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _startPeopleDetection() {
    // Run detection every 200ms
    _detectionTimer =
        Timer.periodic(const Duration(milliseconds: 200), (timer) {
      _detectPeople();
    });
  }

  Future<void> _detectPeople() async {
    if (!_isCameraActive) return;

    try {
      // Check if video element exists and has valid dimensions
      if (_videoElement == null ||
          _videoElement!.videoWidth == 0 ||
          _videoElement!.videoHeight == 0) {
        print('Video element not ready for detection');
        return;
      }

      // Check if video is playing
      if (_videoElement!.paused || _videoElement!.ended) {
        print('Video is not playing, attempting to play...');
        await _videoElement!.play().catchError((e) {
          print('Error playing video: $e');
        });

        // If still not playing, skip detection
        if (_videoElement!.paused || _videoElement!.ended) {
          print('Video still not playing, skipping detection');
          return;
        }
      }

      // Call JavaScript function to count people via JsInterop
      final count = await JsInterop.countPeople(_videoElementId);

      setState(() {
        _peopleCount = count;
      });
    } catch (e) {
      print('Error detecting people: $e');
      // Also print the stack trace for more detailed debugging
      print('Stack trace: ${StackTrace.current}');
    }
  }

  void _stopCamera() {
    if (_videoElement != null && _videoElement!.srcObject != null) {
      final tracks = _videoElement!.srcObject!.getTracks();
      for (final track in tracks) {
        track.stop();
      }
      _videoElement!.srcObject = null;
    }
    setState(() {
      _isCameraActive = false;
      _peopleCount = 0;
    });
  }

  void _toggleCamera() {
    if (_isCameraActive) {
      _stopCamera();
      _detectionTimer?.cancel();
    } else {
      // Force a rebuild to show the video element
      setState(() {
        _isCameraActive = false;
      });

      // Initialize the camera
      _initializeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        backgroundColor: primary,
        elevation: 2,
        foregroundColor: white,
        title: TextWidget(
          text: 'People Counting',
          fontSize: 22,
          color: white,
          fontFamily: 'Bold',
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      TextWidget(
                        text: 'Real-time People Detection',
                        fontSize: 24,
                        color: primary,
                        fontFamily: 'Bold',
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        height: 300,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: primary, width: 2),
                        ),
                        child: _isCameraActive
                            ? const HtmlElementView(
                                viewType: 'webcam-video',
                              )
                            : Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.videocam_off,
                                      size: 80,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 16),
                                    TextWidget(
                                      text: 'Camera is off',
                                      fontSize: 18,
                                      color: Colors.grey[600],
                                      fontFamily: 'Medium',
                                    ),
                                  ],
                                ),
                              ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              TextWidget(
                                text: 'People Detected',
                                fontSize: 18,
                                color: black,
                                fontFamily: 'Medium',
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: primary.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: TextWidget(
                                  text: '$_peopleCount',
                                  fontSize: 36,
                                  color: primary,
                                  fontFamily: 'Bold',
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: _isCameraActive
                                          ? Colors.green
                                          : Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  TextWidget(
                                    text: _isCameraActive
                                        ? 'Detection Active'
                                        : 'Camera Off',
                                    fontSize: 14,
                                    color: _isCameraActive
                                        ? Colors.green
                                        : Colors.red,
                                    fontFamily: 'Medium',
                                  ),
                                ],
                              ),
                            ],
                          ),
                          ButtonWidget(
                            label: _isCameraActive
                                ? 'Stop Camera'
                                : 'Start Camera',
                            onPressed: _toggleCamera,
                            color: _isCameraActive ? Colors.red : primary,
                            textColor: white,
                            width: 150,
                            height: 50,
                            fontSize: 16,
                            radius: 10,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextWidget(
                        text: 'How it works',
                        fontSize: 18,
                        color: primary,
                        fontFamily: 'Bold',
                      ),
                      const SizedBox(height: 10),
                      TextWidget(
                        text: '1. Click "Start Camera" to enable your webcam',
                        fontSize: 16,
                        color: black,
                        fontFamily: 'Regular',
                      ),
                      const SizedBox(height: 5),
                      TextWidget(
                        text:
                            '2. The system will use AI to detect people in real-time',
                        fontSize: 16,
                        color: black,
                        fontFamily: 'Regular',
                      ),
                      const SizedBox(height: 5),
                      TextWidget(
                        text:
                            '3. The count will update automatically every 200ms',
                        fontSize: 16,
                        color: black,
                        fontFamily: 'Regular',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
