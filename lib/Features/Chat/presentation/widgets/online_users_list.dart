import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_qreate_teams/Common/colors.dart';

class OnlineUsersList extends StatelessWidget {
  final Function(String userName) onUserTap;

  const OnlineUsersList({
    super.key,
    required this.onUserTap
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            // Loading indicator or placeholder
            return const CircularProgressIndicator();
          }

          var users = snapshot.data!.docs;

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: users.length,
            itemBuilder: (context, index) {
              var userData = users[index].data() as Map<String, dynamic>;
              var userName = userData['userName'];

              return Padding(
                padding: const EdgeInsets.all(10),
                child: GestureDetector(
                  onTap: () {
                    onUserTap(userName);
                  },
                  child: Stack(
                    children: [
                      Column(
                        children: [
                          // CircleAvatar with the first letter of userName
                          const CircleAvatar(
                            backgroundImage: AssetImage('assets/images/profile_holder_image.png'),
                            radius: 27,
                            backgroundColor: Colors.white,
                          ),
                          const SizedBox(height: 5),
                          Text(
                              userName,
                            style: const TextStyle(
                              fontSize: 11.29
                            ),
                          ),
                        ],
                      ),
                      // Small green circle at the bottom right
                      Positioned(
                        bottom: 29,
                        right: -1,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: ColorName.primaryColor, // Color indicating online status
                            border: Border.all(
                              color: Colors.white, // White color for the stroke
                              width: 2, // Adjust the width of the stroke
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
