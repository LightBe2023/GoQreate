import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_qreate_teams/Common/colors.dart';
import 'package:go_qreate_teams/Features/Chat/presentation/screens/message_screen.dart';
import 'package:go_qreate_teams/Features/Chat/presentation/widgets/online_users_list.dart';
import 'package:go_qreate_teams/services/firebase_service.dart';
import 'package:go_qreate_teams/singleton/user_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatHomeScreen extends StatefulWidget {
  final String? projectId;

  const ChatHomeScreen({
    super.key,
    this.projectId,
  });

  @override
  State<ChatHomeScreen> createState() => _ChatHomeScreenState();
}

class _ChatHomeScreenState extends State<ChatHomeScreen> {
  final FirebaseService firebaseService = FirebaseService();

  late String firstLetter;

  @override
  void initState() {
    firstLetter = '';

    getUsername();
    super.initState();
  }

  Future<void> getUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? userName = prefs.getString('userName');

    if (userName != null) {
      setState(() {
        firstLetter = userName.isNotEmpty ? userName[0].toUpperCase() : '?';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: CircleAvatar(
            backgroundColor: ColorName.primaryColor,
            child: Text(
              firstLetter,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.white,
              ),
            ),
          ),
        ),
        centerTitle: true,
        title: const Text(
          'Chats',
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 18,
            color: Color(0xff6A6A6A),
          ),
          textAlign: TextAlign.start,
        ),
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.white,
          statusBarBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.dark,
        ),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            // Search box
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: TextField(
                onChanged: (value) {
                  // Add your search logic here
                },
                style: const TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 13,
                  color: Colors.black54,
                ),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.only(top: 13, bottom: 13, left: 8, right: 8),
                  prefixIcon: Image.asset(
                    'assets/icons/search_icon.jpg',
                    width: 18.0,
                    height: 18.0,
                  ),
                  hintText: 'Search',
                  hintStyle: const TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.transparent),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.transparent),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 2,),

            // Lists of online users
            OnlineUsersList(
              onUserTap: (userName) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MessageScreen(recipientUserName: userName, projectId: widget.projectId),
                  ),
                );
              },
            ),

            // Lists of chats
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: firebaseService.getChatsWithPreview(widget.projectId ?? ''),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  var chatPreviews = snapshot.data!;

                  if (chatPreviews.isEmpty) {
                    return Center(
                      child: Text(
                        'Messages will appear here',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: chatPreviews.length,
                    itemBuilder: (context, index) {
                      var chatPreview = chatPreviews[index];
                      String latestMessage = chatPreview['latestMessage'] ?? '';

                      // Determine the latest message type
                      String latestMessageType = 'Sent a message';
                      if (latestMessage.contains('GIF')) {
                        latestMessageType = 'Sent a GIF';
                      } else if (latestMessage.contains('Image')) {
                        latestMessageType = 'Sent an image';
                      } else {
                        // If it's a text message, show the message with a maximum of one line and three dots at the end
                        latestMessageType = latestMessage.length > 30
                            ? '${latestMessage.substring(0, 30)}...'
                            : latestMessage;
                      }

                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const CircleAvatar(
                          radius: 25,
                          backgroundImage: AssetImage('assets/images/profile_holder_image.png'),
                          backgroundColor: Colors.white,
                        ),
                        title: Text(chatPreview['userName']),
                        subtitle: Text(latestMessageType),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MessageScreen(recipientUserName: chatPreview['userName']),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
