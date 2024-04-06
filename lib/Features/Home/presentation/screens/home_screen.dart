import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_qreate_teams/Common/custom_navigation_bar.dart';
import 'package:go_qreate_teams/Common/custom_wave.dart';
import 'package:go_qreate_teams/Common/stack_image.dart';
import 'package:go_qreate_teams/Features/Chat/presentation/screens/chat_home_screen.dart';
import 'package:go_qreate_teams/Features/Home/presentation/screens/search_screen.dart';
import 'package:go_qreate_teams/Features/Home/presentation/widgets/project_cards_widget.dart';
import 'package:go_qreate_teams/Features/Notifications/presentation/screens/notification_screen.dart';
import 'package:go_qreate_teams/Features/Profile/presentation/screens/profile_screen.dart';
import 'package:go_qreate_teams/Features/Project/presentation/screens/all_project_screen.dart';
import 'package:go_qreate_teams/Features/Project/presentation/screens/new_project_screen.dart';
import 'package:go_qreate_teams/Features/Project/presentation/screens/project_details_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_stack/image_stack.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  List<ProjectCard> projectCards = [];
  late SharedPreferences prefs;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    initializePreferences();
  }

  Future<void> initializePreferences() async {
    // Initialize prefs and wait for it to complete
    await getCurrentUser();
    // Once prefs is initialized, fetch project data
    fetchProjectDataStream();
  }

  Future<void> getCurrentUser() async {
    // Initialize prefs
    prefs = await SharedPreferences.getInstance();
  }

  Stream<List<ProjectCard>> fetchProjectDataStream() async* {
    // Create a stream controller
    var controller = StreamController<List<ProjectCard>>();

    try {
      // Query projects where the current user is the owner
      QuerySnapshot<Map<String, dynamic>> ownerSnapshot =
      await FirebaseFirestore.instance
          .collection('projects')
          .where('userName', isEqualTo: prefs.getString('userName'))
          .get();

      // Query projects where the current user is a member
      QuerySnapshot<Map<String, dynamic>> memberSnapshot =
      await FirebaseFirestore.instance.collection('projects').get();

      // List to hold the project cards
      List<ProjectCard> projectCards = [];

      for (var doc in memberSnapshot.docs) {
        await FirebaseFirestore.instance
            .collection('projects')
            .doc(doc.id)
            .collection('members')
            .where('userName', isEqualTo: prefs.getString('userName'))
            .get();
      }

      // Process owner projects
      if (ownerSnapshot.docs.isNotEmpty) {
        for (QueryDocumentSnapshot<Map<String, dynamic>> doc
        in ownerSnapshot.docs) {
          List memberImages = await getMemberImages(doc);
          projectCards.add(ProjectCard(
            projectId: doc.id,
            title: doc.get('title') ?? "",
            details: doc.get('details') ?? "",
            members: memberImages,
            startDate: doc.get('start_date')?.toDate(),
            endDate: doc.get('end_date')?.toDate(),
            userName: prefs.getString('userName') ?? "",
          ));
        }
      } else {
        // Process member projects
        if (memberSnapshot.docs.isNotEmpty) {
          for (QueryDocumentSnapshot<Map<String, dynamic>> doc
          in memberSnapshot.docs) {
            List memberImages = await getMemberImages(doc);
            projectCards.add(ProjectCard(
              projectId: doc.id,
              title: doc.get('title') ?? "",
              details: doc.get('details') ?? "",
              members: memberImages,
              startDate: doc.get('start_date')?.toDate(),
              endDate: doc.get('end_date')?.toDate(),
              userName: prefs.getString('userName') ?? "",
            ));
          }
        }
      }

      // Add the projectCards list to the stream
      controller.add(projectCards);
      // Close the stream when done
      controller.close();
    } catch (e) {
      // Handle errors
      print("Error fetching data: $e");
      controller.addError(e);
    }

    // Yield the stream
    yield* controller.stream;
  }


  Future<List> getMemberImages(QueryDocumentSnapshot<Map<String, dynamic>> doc) async {
    QuerySnapshot<Map<String, dynamic>> membersSnapshot =
    await doc.reference.collection('members').get();
    return membersSnapshot.docs.map((memberDoc) =>
    memberDoc.get('profileImage').toString().isNotEmpty
        ? memberDoc.get('profileImage')
        : memberDoc.get('userName')).toList();
  }



  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardHalfWidth = (screenWidth / 3) / 2;

    return Scaffold(
      bottomNavigationBar: CustomBottomNavigationBar(
        // Pass a callback function to handle index changes
        onIndexChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      floatingActionButton: SizedBox(
        width: 44,
        height: 44,
        child: Builder(
          builder: (context) => FloatingActionButton(
            backgroundColor: const Color(0xFF0AD3FF),
            elevation: 0,
            onPressed: () {
              _showOptionsPopup(context);
            },
            child: const Icon(
              Icons.add,
              size: 30,
            ),
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // Return different screens based on the selected index
    switch (_currentIndex) {
      case 0:
        return homeTab();
      case 1:
        return Container(
          // Replace this with your CalendarScreen content
          child: Center(
            child: Text('Calendar Screen'),
          ),
        );
      case 2:
        return const NotificationScreen();
      case 3:
        return const ProfileScreen();
      default:
        return Container();
    }
  }

  Widget homeTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(left: 15, right: 15, top: 70, bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Image.asset(
                      'assets/images/logo_image.png',
                      fit: BoxFit.contain,
                      width: 46,
                    ),
                    const SizedBox(width: 10,),
                    Text(
                      'TEAMS',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 17,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20,),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SearchScreen()), // Navigate to the search screen
                );
              },
              style: ElevatedButton.styleFrom(
                elevation: 2, backgroundColor: Colors.white, // Button color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 13, bottom: 13),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/icons/search_icon.jpg',
                      width: 18.0,
                      height: 18.0,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Search',
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20,),
            Text(
              '"Passion ignites creativity: a project fuels the flame."',
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.normal,
                  fontSize: 11,
                  fontStyle: FontStyle.italic
              ),
            ),

            const SizedBox(height: 30,),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     Text(
            //       'Notes',
            //       style: GoogleFonts.poppins(
            //           fontWeight: FontWeight.w600,
            //           fontSize: 16,
            //       ),
            //     ),
            //     Text(
            //       'See All',
            //       style: GoogleFonts.poppins(
            //         fontWeight: FontWeight.w500,
            //         fontSize: 10,
            //         color: const Color(0xFF0AD3FF),
            //       ),
            //     ),
            //   ],
            // ),
            //
            // const SizedBox(height: 10,),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     SizedBox(
            //       width: screenWidth / 3.4,
            //       height: 80,
            //       child: Card(
            //         shape: RoundedRectangleBorder(
            //           borderRadius: BorderRadius.circular(10),
            //         ),
            //         elevation: 3,
            //         child: Stack(
            //           children: [
            //             Padding(
            //               padding: const EdgeInsets.only(top: 6, left: 10),
            //               child: Positioned(
            //                 top: 0,
            //                 left: 0,
            //                 child: Text(
            //                   '19',
            //                   style: GoogleFonts.poppins(
            //                       fontWeight: FontWeight.normal,
            //                       fontSize: 8,
            //                     color: const Color(0xFFFDBF06),
            //                   ),
            //                 ),
            //               ),
            //             ),
            //             Row(
            //               mainAxisAlignment: MainAxisAlignment.end,
            //               children: [
            //                 ClipRRect(
            //                   borderRadius: BorderRadius.only(
            //                     topRight: Radius.circular(10),
            //                   ),
            //                   child: CustomPaint(
            //                     size: Size(cardHalfWidth, (cardHalfWidth * 0.5833333333333334).toDouble()),
            //                     painter: RPSCustomPainter(color: const Color(0xFFFDBF06)),
            //                   ),
            //                 ),
            //               ],
            //             ),
            //             Padding(
            //               padding: const EdgeInsets.only(top: 25, left: 10, right: 30),
            //               child: Text(
            //                 '3d Making Project',
            //                 style: TextStyle(
            //                   fontWeight: FontWeight.w500,
            //                   fontSize: 10.0,
            //                   color: Colors.black,
            //                   height: 1.3
            //                 ),
            //               ),
            //             ),
            //           ],
            //         ),
            //       ),
            //     ),
            //     const SizedBox(width: 5,),
            //     SizedBox(
            //       width: screenWidth / 3.4,
            //       height: 80,
            //       child: Card(
            //         shape: RoundedRectangleBorder(
            //           borderRadius: BorderRadius.circular(10),
            //         ),
            //         elevation: 3,
            //         child: Stack(
            //           children: [
            //             Padding(
            //               padding: const EdgeInsets.only(top: 6, left: 10),
            //               child: Positioned(
            //                 top: 0,
            //                 left: 0,
            //                 child: Text(
            //                   '19',
            //                   style: GoogleFonts.poppins(
            //                     fontWeight: FontWeight.normal,
            //                     fontSize: 8,
            //                     color: const Color(0xFF009E7D),
            //                   ),
            //                 ),
            //               ),
            //             ),
            //             Row(
            //               mainAxisAlignment: MainAxisAlignment.end,
            //               children: [
            //                 ClipRRect(
            //                   borderRadius: BorderRadius.only(
            //                     topRight: Radius.circular(10),
            //                   ),
            //                   child: CustomPaint(
            //                     size: Size(cardHalfWidth, (cardHalfWidth * 0.5833333333333334).toDouble()),
            //                     painter: RPSCustomPainter(color: const Color(0xFF009E7D)),
            //                   ),
            //                 ),
            //               ],
            //             ),
            //             Padding(
            //               padding: const EdgeInsets.only(top: 25, left: 10, right: 30),
            //               child: Text(
            //                 '3d Making Project',
            //                 style: TextStyle(
            //                     fontWeight: FontWeight.w500,
            //                     fontSize: 10.0,
            //                     color: Colors.black,
            //                     height: 1.3
            //                 ),
            //               ),
            //             ),
            //           ],
            //         ),
            //       ),
            //     ),
            //     const SizedBox(width: 5,),
            //     SizedBox(
            //       width: screenWidth / 3.4,
            //       height: 80,
            //       child: Card(
            //         shape: RoundedRectangleBorder(
            //           borderRadius: BorderRadius.circular(10),
            //         ),
            //         elevation: 3,
            //         child: Stack(
            //           children: [
            //             Padding(
            //               padding: const EdgeInsets.only(top: 6, left: 10),
            //               child: Positioned(
            //                 top: 0,
            //                 left: 0,
            //                 child: Text(
            //                   '19',
            //                   style: GoogleFonts.poppins(
            //                     fontWeight: FontWeight.normal,
            //                     fontSize: 8,
            //                     color: const Color(0xFFA3BCFC),
            //                   ),
            //                 ),
            //               ),
            //             ),
            //             Row(
            //               mainAxisAlignment: MainAxisAlignment.end,
            //               children: [
            //                 ClipRRect(
            //                   borderRadius: BorderRadius.only(
            //                     topRight: Radius.circular(10),
            //                   ),
            //                   child: CustomPaint(
            //                     size: Size(cardHalfWidth, (cardHalfWidth * 0.5833333333333334).toDouble()),
            //                     painter: RPSCustomPainter(color: const Color(0xFFA3BCFC)),
            //                   ),
            //                 ),
            //               ],
            //             ),
            //             Padding(
            //               padding: const EdgeInsets.only(top: 25, left: 10, right: 30),
            //               child: Text(
            //                 '3d Making Project',
            //                 style: TextStyle(
            //                     fontWeight: FontWeight.w500,
            //                     fontSize: 10.0,
            //                     color: Colors.black,
            //                     height: 1.3
            //                 ),
            //               ),
            //             ),
            //           ],
            //         ),
            //       ),
            //     )
            //   ],
            // ),
            //
            // const SizedBox(height: 30,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Projects',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const AllProjectScreen(),
                      ),
                    );
                  },
                  child: Text(
                    'See All',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: 10,
                      color: const Color(0xFF0AD3FF),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10,),

            StreamBuilder<List<ProjectCard>>(
              stream: fetchProjectDataStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator(); // Show loading indicator while data is loading
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  List<ProjectCard>? projectCards = snapshot.data;
                  if (projectCards != null && projectCards.isNotEmpty) {
                    return ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: projectCards.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            // Handle the tap for the specific item (index) here
                            // You can navigate to another screen or perform any action
                            print('Item tapped: $index');

                            // Navigate to ProjectDetailsScreen and pass the document ID
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => ProjectDetailsScreen(projectId: projectCards[index].projectId),
                              ),
                            );
                          },
                          child: projectCards[index],
                        );
                      },
                    );
                } else {
                    return Text('No projects found.');
                  }
                }
              },
            ),

          ],
        ),
      ),
    );
  }
}

void _showOptionsPopup(BuildContext context) async {
  final RenderBox button = context.findRenderObject() as RenderBox;

  final Offset buttonPosition = button.localToGlobal(Offset.zero);

  final double bottomOffset = MediaQuery.of(context).size.height - buttonPosition.dy - button.size.height + 450.0;
  final double rightOffset = MediaQuery.of(context).size.width - buttonPosition.dx - button.size.width + 50.0;

  final RelativeRect position = RelativeRect.fromLTRB(
    rightOffset,  // left
    bottomOffset + 30,  // top
    40,  // right
    0.0,  // bottom
  );

  await showMenu(
    context: context,
    position: position,
    items: [
      _buildOption('New Project', 'assets/icons/new_project.png', context),
      // _buildOption('New Notes', 'assets/icons/new_notes.png', context),
      _buildOption('New Message', 'assets/icons/new_message.png', context),
    ],
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  );
}

PopupMenuItem _buildOption(String text, String imagePath, BuildContext context) {
  return PopupMenuItem(
    child: InkWell(
      onTap: () {
        if (text.contains('New Project')) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const NewProjectScreen()),
          );
        }

        if (text.contains('New Message')) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const ChatHomeScreen()),
          );
        }
      },
      child: Row(
        children: [
          Image.asset(imagePath, width: 22, height: 22),
          const SizedBox(width: 12),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.normal,
              fontSize: 11,
              color: Colors.black,
            ),
          ),
        ],
      ),
    ),
  );
}
