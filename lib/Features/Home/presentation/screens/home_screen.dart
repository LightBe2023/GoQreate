import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_qreate_teams/Common/custom_navigation_bar.dart';
import 'package:go_qreate_teams/Common/custom_wave.dart';
import 'package:go_qreate_teams/Common/stack_image.dart';
import 'package:go_qreate_teams/Features/Home/presentation/widgets/project_cards_widget.dart';
import 'package:go_qreate_teams/Features/Project/presentation/screens/new_project_screen.dart';
import 'package:go_qreate_teams/Features/Project/presentation/screens/project_details_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_stack/image_stack.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  List<ProjectCard> projectCards = [];

  @override
  void initState() {
    super.initState();
    // Call the function to fetch project data when the screen is initialized
    fetchProjectData();
  }

  Future<void> fetchProjectData() async {
    try {
      String userName = "jerwel"; // Replace with the actual userName

      // Query to fetch data where 'userName' is equal to the specified value
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
          .collection('projects')
          .where('userName', isEqualTo: userName)
          .get();

      // Check if any documents were found
      if (querySnapshot.docs.isNotEmpty) {
        projectCards = querySnapshot.docs.map((doc) {
          return ProjectCard(
            title: doc.get('title') ?? "",
            details: doc.get('details') ?? "",
          );
        }).toList();

        setState(() {});
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardHalfWidth = (screenWidth / 3) / 2;

    return Scaffold(
      bottomNavigationBar: CustomBottomNavigationBar(),
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
      body: SingleChildScrollView(
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
                  Image.asset(
                    'assets/icons/add_member.png',
                    fit: BoxFit.contain,
                    width: 28,
                  ),
                ],
              ),

              const SizedBox(height: 20,),
              ElevatedButton(
                onPressed: () {
                  // Add your search logic here
                },
                style: ElevatedButton.styleFrom(
                  elevation: 2, // Adjust the elevation as needed
                  primary: Colors.white, // Button color
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Notes',
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                    ),
                  ),
                  Text(
                    'See All',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: 10,
                      color: const Color(0xFF0AD3FF),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: screenWidth / 3.4,
                    height: 80,
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 3,
                      child: Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 6, left: 10),
                            child: Positioned(
                              top: 0,
                              left: 0,
                              child: Text(
                                '19',
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 8,
                                  color: const Color(0xFFFDBF06),
                                ),
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(10),
                                ),
                                child: CustomPaint(
                                  size: Size(cardHalfWidth, (cardHalfWidth * 0.5833333333333334).toDouble()),
                                  painter: RPSCustomPainter(color: const Color(0xFFFDBF06)),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 25, left: 10, right: 30),
                            child: Text(
                              '3d Making Project',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 10.0,
                                color: Colors.black,
                                height: 1.3
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 5,),
                  SizedBox(
                    width: screenWidth / 3.4,
                    height: 80,
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 3,
                      child: Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 6, left: 10),
                            child: Positioned(
                              top: 0,
                              left: 0,
                              child: Text(
                                '19',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 8,
                                  color: const Color(0xFF009E7D),
                                ),
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(10),
                                ),
                                child: CustomPaint(
                                  size: Size(cardHalfWidth, (cardHalfWidth * 0.5833333333333334).toDouble()),
                                  painter: RPSCustomPainter(color: const Color(0xFF009E7D)),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 25, left: 10, right: 30),
                            child: Text(
                              '3d Making Project',
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 10.0,
                                  color: Colors.black,
                                  height: 1.3
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 5,),
                  SizedBox(
                    width: screenWidth / 3.4,
                    height: 80,
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 3,
                      child: Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 6, left: 10),
                            child: Positioned(
                              top: 0,
                              left: 0,
                              child: Text(
                                '19',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 8,
                                  color: const Color(0xFFA3BCFC),
                                ),
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(10),
                                ),
                                child: CustomPaint(
                                  size: Size(cardHalfWidth, (cardHalfWidth * 0.5833333333333334).toDouble()),
                                  painter: RPSCustomPainter(color: const Color(0xFFA3BCFC)),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 25, left: 10, right: 30),
                            child: Text(
                              '3d Making Project',
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 10.0,
                                  color: Colors.black,
                                  height: 1.3
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),

              const SizedBox(height: 30,),
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
                  Text(
                    'See All',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: 10,
                      color: const Color(0xFF0AD3FF),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10,),

              ListView.builder(
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

                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ProjectDetailsScreen(),
                        ),
                      );
                    },
                    child: projectCards[index],
                  );
                },
              ),
            ],
          ),
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
    bottomOffset,  // top
    40,  // right
    0.0,  // bottom
  );

  await showMenu(
    context: context,
    position: position,
    items: [
      _buildOption('New Project', 'assets/icons/new_project.png', context),
      _buildOption('New Notes', 'assets/icons/new_notes.png', context),
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
