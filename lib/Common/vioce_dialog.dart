import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

typedef void OnRecordingStopped(String audioFilePath);

class VoiceDetectionDialog extends StatefulWidget {
  final OnRecordingStopped onRecordingStopped;

  const VoiceDetectionDialog({required this.onRecordingStopped});

  @override
  _VoiceDetectionDialogState createState() => _VoiceDetectionDialogState();
}

class _VoiceDetectionDialogState extends State<VoiceDetectionDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    )..repeat(reverse: true);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: _buildDialogContent(),
    );
  }

  Widget _buildDialogContent() {
    return Container(
      height: 150,
      width: 150,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: ScaleTransition(
          scale: _animation,
          child: GestureDetector(
            onTap: () {
              _stopRecording();
            },
            child: Icon(
              Icons.mic,
              size: 50,
              color: Colors.blue,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _stopRecording() async {
    try {
      // Implement your logic to stop recording here
      String audioFilePath = ''; // Placeholder for audio file path
      widget.onRecordingStopped(audioFilePath);
      Navigator.of(context).pop();
    } catch (e) {
      print('Failed to stop recording: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
