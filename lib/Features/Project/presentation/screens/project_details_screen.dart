import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_qreate_teams/Common/colors.dart';
import 'package:go_qreate_teams/Features/Chat/presentation/screens/chat_home_screen.dart';
import 'package:go_qreate_teams/Features/Home/presentation/screens/home_screen.dart';
import 'package:go_qreate_teams/Features/Milestone/presentation/screens/milestone_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:avatar_stack/avatar_stack.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import 'all_file_screen.dart';

class ProjectDetailsScreen extends StatefulWidget {
  final String projectId;

  const ProjectDetailsScreen({
    required this.projectId,
    super.key,
  });

  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  List<String?> selectedFiles = List.filled(5, null);
  String title = "";
  String projectDetails = "";
  String budget = "";
  DateTime? _startDate;
  DateTime? _endDate;

  late TextEditingController projectDetailsController;

  List _memberImages = [];
  String _projectId = '';
  String _searchedUserName = '';
  List _milestones = [];
  String _milestoneStatus = '';

  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    projectDetailsController = TextEditingController();

    // Fetch data from Firestore and update the state
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      // Fetch the project data based on the provided projectId
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
          .collection('projects')
          .doc(widget.projectId) // Use the provided projectId
          .get();

      if (snapshot.exists) {
        setState(() {
          title = snapshot.get('title') ?? "";
          projectDetails = snapshot.get('details') ?? "";
          budget = snapshot.get('budget') ?? "";
          _startDate = (snapshot.get('start_date') as Timestamp?)?.toDate();
          _endDate = (snapshot.get('end_date') as Timestamp?)?.toDate();
          _milestones = List.from(snapshot.get('milestones') ?? []);
          _milestoneStatus = snapshot.get('milestoneStatus') ?? "";

          // Retrieve fileUrls array from the document
          List<String>? fileUrls = List<String>.from(snapshot.get('fileUrls') ?? []);

          // Update selectedFiles list with retrieved fileUrls
          for (int i = 0; i < fileUrls.length; i++) {
            selectedFiles[i] = fileUrls[i];
          }
        });

        if (projectDetails.isNotEmpty) {
          projectDetailsController = TextEditingController(text: projectDetails);
        }

        // Fetch members' data from the 'members' subcollection
        QuerySnapshot<Map<String, dynamic>> membersSnapshot = await snapshot.reference.collection('members').get();

        // Extract member images from the 'profileImage' field
        List memberImages = membersSnapshot.docs
            .map((memberDoc) =>
        memberDoc.get('profileImage').toString().isNotEmpty
            ? memberDoc.get('profileImage')
            : memberDoc.get('userName'))
            .toList();

        setState(() {
          _memberImages = memberImages;
          _projectId = snapshot.id; // Use the ID of the fetched document as projectId
        });
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }


  double calculateProgressPercentage() {
    DateTime currentDate = DateTime.now();
    DateTime? startDate = _startDate;
    DateTime? endDate = _endDate;

    if (startDate != null && endDate != null) {
      if (currentDate.isBefore(startDate)) {
        // Project has not started yet
        return 0.0;
      } else if (currentDate.isAfter(endDate)) {
        // Project has already ended
        return 1.0;
      } else {
        // Calculate the progress based on the current date
        Duration totalDuration = endDate.difference(startDate);
        Duration elapsedDuration = currentDate.difference(startDate);
        double progress = elapsedDuration.inMilliseconds / totalDuration.inMilliseconds;
        return progress.clamp(0.0, 1.0);
      }
    }

    // Return 0.0 if start or end date is null
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: () async {
        return await Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      },
      child: Scaffold(
        appBar: AppBar(
          leading: Padding(
            padding: const EdgeInsets.only(left: 20, top: 5, bottom: 5, right: 5),
            child: Image.asset(
              'assets/images/logo_image.png',
              fit: BoxFit.contain,
            ),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 220,
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  _showSearchPopup(context, _projectId);
                },
                child: Image.asset(
                  'assets/icons/add_member.png',
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
          elevation: 0,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarBrightness: Brightness.light,
            statusBarIconBrightness: Brightness.dark,
          ),
          backgroundColor: Colors.transparent,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(
                  width: double.infinity,
                  child: Text(
                    'Details',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                      color: Color(0xff6A6A6A),
                    ),
                    textAlign: TextAlign.start,
                  ),
                ),
                const SizedBox(height: 5,),
                Container(
                  width: double.infinity,
                  height: 139,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 0.1,
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: TextFormField(
                    controller: projectDetailsController,
                    maxLines: null,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(15),
                      border: InputBorder.none,
                      hintStyle: TextStyle(
                        color: Colors.grey.withOpacity(0.8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20,),
                const SizedBox(
                  width: double.infinity,
                  child: Text(
                    'Team',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.start,
                  ),
                ),
                const SizedBox(height: 5,),
                Row(
                  children: [
                    SizedBox(
                      height: screenWidth / 12,
                      width: screenWidth / 3.1,
                      child: Stack(
                        children: [
                          for (int i = 0; i < _memberImages.length && i < 4; i++)
                            Positioned(
                              left: i * 20.0,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 1,
                                  ), // White stroke
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child: _memberImages[i].toString().contains('http')
                                      ? Image.network(
                                    _memberImages[i],
                                    width: 28,
                                    height: 28,
                                    fit: BoxFit.cover,
                                  )
                                      : Container(
                                    width: 28,
                                    height: 28,
                                    color: Colors.grey, // Placeholder color
                                    child: Center(
                                      child: Text(
                                        _memberImages[i][0],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ), // Add placeholder members if less than 4
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Message',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const ChatHomeScreen()),
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
                const SizedBox(height: 5,),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const ChatHomeScreen()),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    height: 55,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 0.1,
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Files',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => AllFileScreen(selectedFiles: selectedFiles),
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
                const SizedBox(height: 5,),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                    5,
                        (index) {
                      return GestureDetector(
                        onTap: () async {
                          // FilePickerResult? result = await FilePicker.platform.pickFiles();
                          // if (result != null && result.files.isNotEmpty) {
                          //   setState(() {
                          //     selectedFiles[index] = result.files.first.path;
                          //   });
                          // }
                        },
                        child: Card(
                          elevation: 1,
                          child: SizedBox(
                            height: 89,
                            width: 56,
                            child: selectedFiles[index] != null
                                ? selectedFiles[index]!.contains('http') || selectedFiles[index]!.contains('https')
                                ? Image.network(
                              selectedFiles[index]!,
                              fit: BoxFit.cover,
                            )
                                : Image.file(
                              File(selectedFiles[index]!), // Convert string path to File
                              fit: BoxFit.cover,
                            )
                                :
                                Container()
                            // Icon(
                            //   Icons.add,
                            //   size: 14,
                            //   color: ColorName.primaryColor,
                            // ),
                          ),
                        ),
                      );
                    },
                  ),
                ),


                const SizedBox(height: 15,),
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    'Milestone Progress',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 5,),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => MilestoneScreen(
                            milestones: _milestones,
                            projectId: _projectId,
                          title: title,
                          details: projectDetails,
                          startDate: _startDate,
                        ),
                      ),
                    );
                  },
                  child: LinearPercentIndicator(
                    padding: EdgeInsets.zero,
                    barRadius: const Radius.circular(10),
                    lineHeight: 15,
                    percent: calculateProgressPercentage(),
                    backgroundColor: ColorName.primaryColor.withOpacity(0.2),
                    progressColor: const Color(0xFF0AD3FF),
                  ),
                ),
                // const SizedBox(height: 20,),
                // SizedBox(
                //   width: double.infinity,
                //   child: Text(
                //     'Budget: $budget',
                //     style: GoogleFonts.poppins(
                //       fontWeight: FontWeight.w400,
                //       fontSize: 16,
                //       color: ColorName.primaryColor,
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSearchPopup(BuildContext context, String projectId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add member'),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              content: Container(
                width: MediaQuery.of(context).size.width - 100, // Adjust width as needed
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: searchController,
                      onChanged: (value) async {
                        setState(() {
                          _searchedUserName = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search user',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 20),
                    if (_searchedUserName.isNotEmpty)
                      FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        future: FirebaseFirestore.instance
                            .collection('users')
                            .where('userName', isEqualTo: _searchedUserName)
                            .get(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[200], // Adjust the color for contrast
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: snapshot.data!.docs.length,
                                itemBuilder: (context, index) {
                                  String userName = snapshot.data!.docs[index].get('userName');
                                  return ListTile(
                                    title: Text(userName),
                                    onTap: () {
                                      _addMemberToProject(projectId, userName, context);
                                      Navigator.of(context).pop();
                                    },
                                  );
                                },
                              ),
                            );
                          } else {
                            return Text('No users found');
                          }
                        },
                      ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        // Check if the user with the entered username exists
                        if (_searchedUserName.isNotEmpty) {
                          // Assuming you have a function to add a member to the project
                          _addMemberToProject(projectId, _searchedUserName, context);

                          // Close the search popup
                          Navigator.of(context).pop();
                        } else {
                          // Show a message indicating that the user was not found
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('User not found'),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        primary: ColorName.primaryColor,
                      ),
                      child: const Text('ADD'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _addMemberToProject(String projectId, String userName, BuildContext context) async {
    try {
      // Get the project reference
      DocumentReference<Map<String, dynamic>> projectRef =
      FirebaseFirestore.instance.collection('projects').doc(projectId);

      // Check if the user is already a member of the project
      QuerySnapshot<Map<String, dynamic>> existingMembersSnapshot =
      await projectRef.collection('members').where('userName', isEqualTo: userName).get();

      if (existingMembersSnapshot.docs.isEmpty) {
        // If the user is not already a member, add them to the 'members' subcollection
        await projectRef.collection('members').add({
          'userName': userName,
          'profileImage': '',
        });

        // Update UI by fetching data again
        await fetchData();

        // Show a success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$userName added to the project'),
          ),
        );
      } else {
        // Show a message indicating that the user is already a member
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$userName is already a member of the project'),
          ),
        );
      }
    } catch (e) {
      print('Error adding member to project: $e');
    }
  }

}