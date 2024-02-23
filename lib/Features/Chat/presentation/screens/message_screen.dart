import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:giphy_get/giphy_get.dart';
import 'package:go_qreate_teams/Common/colors.dart';
import 'package:go_qreate_teams/services/firebase_service.dart';
import 'package:go_qreate_teams/singleton/user_manager.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MessageScreen extends StatefulWidget {
  final String recipientUserName;

  const MessageScreen({
    super.key,
    required this.recipientUserName,
  });

  @override
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final FirebaseService firebaseService = FirebaseService();
  final TextEditingController _messageController = TextEditingController();

  final ImagePicker _imagePicker = ImagePicker();

  final FlutterSoundPlayer _audioPlayer = FlutterSoundPlayer();
  final FlutterSoundRecorder _audioRecorder = FlutterSoundRecorder();
  late String _audioFilePath;
  bool _isRecording = false;
  bool _isPlaying = false;
  StreamSubscription? _audioPlayerSubscription;
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    _audioFilePath = '';
    // _initAudioRecorder();
    // _initAudioPlayer();
    initSharedPreferences();
  }

  Future<void> initSharedPreferences() async {
     prefs = await SharedPreferences.getInstance();
  }

  // Future<void> _initAudioRecorder() async {
  //   try {
  //     await _audioRecorder.openRecorder();
  //   } catch (e) {
  //     print('Failed to initialize audio recorder: $e');
  //   }
  // }
  //
  // Future<void> _initAudioPlayer() async {
  //   try {
  //     await _audioPlayer.openPlayer();
  //   } catch (e) {
  //     print('Failed to initialize audio player: $e');
  //   }
  // }
  //
  // Future<void> _startRecording() async {
  //   try {
  //     final Directory appDirectory = await getApplicationDocumentsDirectory();
  //     final String filePath = '${appDirectory.path}/audio_message.aac';
  //
  //     await _audioRecorder.startRecorder(
  //       codec: Codec.aacMP4,
  //       toFile: filePath,
  //     );
  //
  //     setState(() {
  //       _audioFilePath = filePath;
  //       _isRecording = true;
  //     });
  //   } catch (e) {
  //     print('Failed to start recording: $e');
  //   }
  // }
  //
  // Future<void> _stopRecording() async {
  //   try {
  //     await _audioRecorder.stopRecorder();
  //     setState(() {
  //       _isRecording = false;
  //     });
  //   } catch (e) {
  //     print('Failed to stop recording: $e');
  //   }
  // }
  //
  // Future<void> _playAudioMessage() async {
  //   try {
  //     setState(() {
  //       _isPlaying = true;
  //     });
  //
  //     await _audioPlayer.startPlayer(
  //       fromURI: _audioFilePath,
  //       codec: Codec.aacMP4,
  //     );
  //
  //     // Listen for player state changes
  //     _audioPlayerSubscription = _audioPlayer.onProgress!.listen((e) {
  //       if (e.position.inMilliseconds >= e.duration.inMilliseconds) {
  //         setState(() {
  //           _isPlaying = false;
  //         });
  //       }
  //     });
  //   } catch (e) {
  //     print('Failed to play audio message: $e');
  //   }
  // }
  //
  // Future<void> _stopAudioMessage() async {
  //   try {
  //     await _audioPlayer.stopPlayer();
  //     setState(() {
  //       _isPlaying = false;
  //     });
  //   } catch (e) {
  //     print('Failed to stop audio message: $e');
  //   }
  // }
  //
  // Future<bool> _checkPermission() async {
  //   if (Platform.isAndroid) {
  //     PermissionStatus status = await Permission.microphone.status;
  //     if (status.isGranted) {
  //       return true;
  //     } else {
  //       PermissionStatus result = await Permission.microphone.request();
  //       return result.isGranted;
  //     }
  //   } else if (Platform.isIOS) {
  //     PermissionStatus status = await Permission.microphone.status;
  //     if (status.isGranted) {
  //       return true;
  //     } else {
  //       PermissionStatus result = await Permission.microphone.request();
  //       return result.isGranted;
  //     }
  //   }
  //   return false;
  // }

  @override
  void dispose() {
    _audioPlayerSubscription?.cancel();
    _audioPlayer.closePlayer();
    _audioRecorder.closeRecorder();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: ColorName.primaryColor,
            size: 20,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        titleSpacing: -5,
        title: Row(
          children: [
            const CircleAvatar(
              backgroundImage: AssetImage('assets/images/profile_holder_image.png'),
              radius: 18,
              backgroundColor: Colors.white,
            ),
            const SizedBox(width: 10),
            Text(
              widget.recipientUserName,
              style: const TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 18,
                color: Colors.black,
              ),
            ),
          ],
        ),
        actions: [
          Image.asset(
            'assets/icons/audio_call_icon.png',
            fit: BoxFit.contain,
            width: 18,
          ),
          const SizedBox(width: 15,),
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Image.asset(
              'assets/icons/video_call_icon.png',
              fit: BoxFit.contain,
              width: 40,
            ),
          ),
        ],
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Body content for message conversations
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: firebaseService.getMessages(widget.recipientUserName),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                var messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var messageData = messages[index].data();
                    var sender = messageData['sender'];
                    var message = messageData['message'];

                    return _buildMessage(sender, message);
                  },
                );
              },
            ),
          ),

          // Row of items
          Padding(
            padding: const EdgeInsets.only(bottom: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          _sendGif(context);
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20, right: 8),
                          child: Image.asset(
                            'assets/icons/gif_icon.png',
                            fit: BoxFit.contain,
                            width: 25,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: GestureDetector(
                          onTap: _takePicture,
                          child: Image.asset(
                            'assets/icons/camera_icon.png',
                            fit: BoxFit.contain,
                            width: 25,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          _pickImageFromGallery();
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Image.asset(
                            'assets/icons/gallery_icon.png',
                            fit: BoxFit.contain,
                            width: 25,
                          ),
                        ),
                      ),
                      // GestureDetector(
                      //   onTap: () async {
                      //     bool granted = await _checkPermission();
                      //     if (granted) {
                      //       _isRecording ? _stopRecording() : _startRecording();
                      //     } else {
                      //       print('Permission not granted');
                      //     }
                      //   },
                      //   child: Padding(
                      //     padding: const EdgeInsets.symmetric(horizontal: 8),
                      //     child: Image.asset(
                      //       _isRecording ? 'assets/icons/mic_icon.png' : 'assets/icons/mic_icon.png',
                      //       fit: BoxFit.contain,
                      //       width: 14,
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                // Message box (with BorderRadius)
                SizedBox(
                    width: 150,
                    height: 37,
                    child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.0),
                          color: const Color(0xFFF5F5F5),
                        ),
                        child: TextField(
                          // Handle text input
                          controller: _messageController,
                          decoration: const InputDecoration(
                            border: InputBorder.none, // Remove the border
                            contentPadding: EdgeInsets.symmetric(horizontal: 8),
                          ),
                        ),
                    ),
                  ),
                // Thumbs up button
                GestureDetector(
                  onTap: () {
                    _sendMessage();
                  },
                  child: const Padding(
                    padding: EdgeInsets.only(right: 20, left: 12),
                    child: Icon(
                      Icons.send,
                      color: ColorName.primaryColor,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendGif(BuildContext context) async {
    GiphyGif? gif = await GiphyGet.getGif(
      context: context,
      apiKey: "RWYnHRQz0ZqlQdYsXHblYiB3rXRV9LIh",
      lang: GiphyLanguage.english,
    );

    if (gif != null) {
      // Extract the URL of the selected GIF
      String? gifUrl = gif.images?.original?.url;

      // Send the GIF message
      firebaseService.sendMessage(
        prefs.getString('userName')!,
        widget.recipientUserName,
        'GIF: $gifUrl', // Placeholder message for the GIF
      );
    }
  }

  // Function to pick images from the gallery
  Future<void> _pickImageFromGallery() async {
    List<XFile>? pickedImages = await _imagePicker.pickMultiImage();

    if (pickedImages.isNotEmpty) {
      // Handle the picked images, you can upload them to Firebase Storage or perform other operations
      // For now, you can display a placeholder message for each image
      for (var image in pickedImages) {
        firebaseService.sendMessage(
          prefs.getString('userName')!,
          widget.recipientUserName,
          'Image: ${image.path}', // Placeholder message for the image
        );
      }
    }
  }


  // Function to send a message
  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      firebaseService.sendMessage(prefs.getString('userName')!, widget.recipientUserName, message);
      _messageController.clear();
    }
  }

  Widget _buildMessage(String sender, String message) {
    final isCurrentUser = sender == prefs.getString('userName');
    final double radius = 15.0;
    Color backgroundColor = isCurrentUser ? ColorName.primaryColor : Colors.black;

    return Padding(
      padding: const EdgeInsets.only(left: 20),
      child: Row(
        mainAxisAlignment: isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isCurrentUser)
            CircleAvatar(
              backgroundImage: AssetImage('assets/images/profile_holder_image.png'), // Replace with the actual image path
              radius: radius,
              backgroundColor: Colors.white,
            ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              decoration: BoxDecoration(
                color: message.startsWith('Image:') || message.startsWith('GIF:') ? null : backgroundColor,
                borderRadius: BorderRadius.only(
                  topLeft: isCurrentUser ? Radius.circular(radius) : Radius.circular(0),
                  topRight: isCurrentUser ? Radius.circular(0) : Radius.circular(radius),
                  bottomLeft: Radius.circular(message.startsWith('Image:') || message.startsWith('GIF:') ? 10.0 : radius),
                  bottomRight: Radius.circular(message.startsWith('Image:') || message.startsWith('GIF:') ? 10.0 : radius),
                ),
                // Add border color and width if necessary
                // border: Border.all(color: Colors.grey, width: 1),
              ),
              child: _buildContent(message),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(String message) {
    if (message.startsWith('Image:')) {
      final imagePath = message.substring(7); // Remove the "Image: " prefix
      return Image.file(
        File(imagePath), // Import 'dart:io' for File class
        width: 150, // Set the width to your desired size
        height: 150, // Set the height to your desired size
        fit: BoxFit.cover,
      );
    } else if (message.startsWith('GIF:')) {
      final gifUrl = message.substring(4).trim(); // Remove the "GIF: " prefix and trim whitespace
      return Image.network(
        gifUrl, // URL of the GIF image
        width: 150, // Set the width to your desired size
        height: 150, // Set the height to your desired size
        fit: BoxFit.cover,
      );
    } else {
      return Text(
        message,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.white,
        ),
      );
    }
  }

  Future<void> _takePicture() async {
    // Request permission if not granted
    if (!(await _checkCameraPermission())) {
      // Handle permission denial
      return;
    }

    final XFile? pickedImage = await _imagePicker.pickImage(source: ImageSource.camera);

    if (pickedImage != null) {
      // Handle the picked image, you can upload it to Firebase Storage or do other operations
      // For now, you can display a placeholder message
      firebaseService.sendMessage(
        prefs.getString('userName')!,
        widget.recipientUserName,
        'Image: ${pickedImage.path}', // Placeholder message for the image
      );
    }
  }

  Future<bool> _checkCameraPermission() async {
    if (Platform.isAndroid) {
      PermissionStatus status = await Permission.camera.status;
      if (status.isGranted) {
        return true;
      } else {
        PermissionStatus result = await Permission.camera.request();
        return result.isGranted;
      }
    } else if (Platform.isIOS) {
      PermissionStatus status = await Permission.camera.status;
      if (status.isGranted) {
        return true;
      } else {
        PermissionStatus result = await Permission.camera.request();
        return result.isGranted;
      }
    }
    return false;
  }


}
