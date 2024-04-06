import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_qreate_teams/Common/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late Future<QuerySnapshot<Map<String, dynamic>>> _notificationsFuture;
  late SharedPreferences prefs;
  late String selectedButton = 'All';
  late String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    initializePreferences();
  }

  void _updateSelectedButton(String buttonName) {
    setState(() {
      selectedButton = buttonName;
    });
  }

  ElevatedButton _buildButton(String buttonText) {
    final isSelected = selectedButton == buttonText;
    return ElevatedButton(
      onPressed: () => _updateSelectedButton(buttonText),
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ), backgroundColor: isSelected ? ColorName.primaryColor : Colors.white,
        elevation: 1,
        padding: EdgeInsets.zero,
      ),
      child: Text(
        buttonText,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 11,
          color: isSelected ? Colors.white : ColorName.primaryColor,
        ),
      ),
    );
  }

  Future<void> initializePreferences() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsFuture = fetchNotifications();
    });
  }

  Future<QuerySnapshot<Map<String, dynamic>>> fetchNotifications() {
    return FirebaseFirestore.instance.collection('notifications')
        .where('receiverUserName', isEqualTo: prefs.getString('userName')) // Replace 'currentUserName' with the actual current username
        .get();
  }

  List<QueryDocumentSnapshot<Map<String, dynamic>>> filterNotifications(QuerySnapshot<Map<String, dynamic>> snapshot) {
    return snapshot.docs.where((doc) {
      final initiatorName = doc['initiatorName'] as String;
      final projectTitle = doc['projectTitle'] as String;
      return initiatorName.contains(_searchQuery) || projectTitle.contains(_searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        title: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Text(
            'Notification',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Colors.black,
            ),
          ),
        ),
        centerTitle: true,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.dark,
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Column(
            children: [
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  padding: EdgeInsets.zero,
                ),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value; // Step 2: Update search query
                      _notificationsFuture = fetchNotifications(); // Step 4: Refresh notifications
                    });
                  },
                  decoration: const InputDecoration(
                    hintText: 'Search',
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),

              const SizedBox(height: 10,),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: 50,
                    height: 40,
                    child: _buildButton('All'),
                  ),
                  SizedBox(
                    width: 60,
                    height: 40,
                    child: _buildButton('Unread'),
                  ),
                  SizedBox(
                    width: 80,
                    height: 40,
                    child: _buildButton('Mentioned'),
                  ),
                  SizedBox(
                    width: 90,
                    height: 40,
                    child: _buildButton('Assigned Me'),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
                future: Future.delayed(const Duration(seconds: 1), () => _notificationsFuture),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (snapshot.hasData) {
                    final filteredNotifications = filterNotifications(snapshot.data!);
                    if (filteredNotifications.isEmpty) {
                      return const Text('No notifications found');
                    }
                    return Column(
                      children: filteredNotifications.map((doc) {
                        String initiatorName = doc['initiatorName'] as String;
                        String projectTitle = doc['projectTitle'] as String;
                        Timestamp timestamp = doc['timestamp'] as Timestamp;
                        DateTime notificationTime = timestamp.toDate();
                        Duration timeDifference = DateTime.now().difference(notificationTime);
                        String formattedTimestamp = _formatTimestamp(timeDifference); // Format the timestamp
                        return Card(
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                radius: 35,
                                backgroundColor: Colors.transparent,
                                child: Image.asset(
                                  'assets/images/profile_holder_image.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                              title: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: initiatorName,
                                      style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 11,
                                          color: Colors.black
                                      ),
                                    ),
                                    TextSpan(
                                      text: ' added you to Project $projectTitle',
                                      style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.normal,
                                          fontSize: 11,
                                          color: Colors.black.withOpacity(0.5)
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 5),
                                    child: Text(
                                      formattedTimestamp,
                                      style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 8,
                                          color: Colors.black.withOpacity(0.5)
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  } else {
                    return const Text('No notifications found');
                  }
                },
              )

            ],
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(Duration timeDifference) {
    if (timeDifference.inDays > 0) {
      return '${timeDifference.inDays}d';
    } else if (timeDifference.inHours > 0) {
      return '${timeDifference.inHours}h';
    } else if (timeDifference.inMinutes > 0) {
      return '${timeDifference.inMinutes}m';
    } else {
      return 'Just now';
    }
  }

}

