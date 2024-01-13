import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_qreate_teams/Common/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:avatar_stack/avatar_stack.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class ProjectDetailsScreen extends StatefulWidget {
  const ProjectDetailsScreen({super.key});

  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {

  List<String?> selectedFiles = List.filled(5, null);
  String title = "";
  String projectDetails = "";
  String budget = "";

  late TextEditingController projectDetailsController;

  @override
  void initState() {
    super.initState();

    projectDetailsController = TextEditingController();

    // Fetch data from Firestore and update the state
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      String userName = "jerwel"; // Replace with the actual userName

      // Query to fetch data where 'userName' is equal to the specified value
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
          .collection('projects')
          .where('userName', isEqualTo: userName)
          .get();

      // Check if any documents were found
      if (querySnapshot.docs.isNotEmpty) {
        // For simplicity, assuming there is only one document with the specified userName
        DocumentSnapshot<Map<String, dynamic>> snapshot = querySnapshot.docs.first;

        setState(() {
          title = snapshot.get('title') ?? "";
          projectDetails = snapshot.get('details') ?? "";
          budget = snapshot.get('budget') ?? "";

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
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }


  @override
  Widget build(BuildContext context) {

    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
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
            Text(
              title,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: Colors.black,
              ),
            ),
            Image.asset(
              'assets/icons/add_member.png',
              fit: BoxFit.contain,
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
                  borderRadius: BorderRadius.circular(6), // Adjust the radius for curved edges
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
                  maxLines: null, // Allow multiple lines
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(15), // Adjust padding as needed
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
                  'TEAMS',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.start,
                ),
              ),

              const SizedBox(height: 5,),

              AvatarStack(
                height: 30,
                avatars: [
                  for (var n = 0; n < 3; n++)
                    NetworkImage('https://i.pravatar.cc/150?img=$n'),
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

              const SizedBox(height: 5,),

              GestureDetector(
                onTap: () {

                },
                child: Container(
                  width: double.infinity,
                  height: 55,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6), // Adjust the radius for curved edges
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

              const SizedBox(height: 5,),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  5, // Updated to generate 5 cards
                      (index) {
                    return GestureDetector(
                      onTap: () async {
                        String? filePath = await FilePicker.platform.pickFiles().then(
                              (value) {
                            if (value != null && value.files.isNotEmpty) {
                              return value.files.first.path;
                            } else {
                              return null;
                            }
                          },
                        );
                        if (filePath != null) {
                          setState(() {
                            selectedFiles[index] = filePath;
                          });

                          // Notify the callback in the parent screen
                          // widget.onFileSelected(filePath);
                        }
                      },
                      child: Card(
                        elevation: 1,
                        child: SizedBox(
                          height: 95,
                          width: 62,
                          child: selectedFiles[index] != null
                              ? Image.network(
                            // Use the selected file as the cover photo
                            selectedFiles[index]!,
                            fit: BoxFit.cover,
                          )
                              : Icon(
                            Icons.add,
                            size: 14,
                            color: ColorName.primaryColor,
                          ),
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

              LinearPercentIndicator(
                    padding: EdgeInsets.zero,
                    barRadius: const Radius.circular(10),
                    lineHeight: 15,
                    percent: 0.5,
                    backgroundColor: ColorName.primaryColor.withOpacity(0.2),
                    progressColor: const Color(0xFF0AD3FF),
                  ),

              const SizedBox(height: 20,),

              SizedBox(
                width: double.infinity,
                child: Text(
                  'Budget: $budget',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                    color: ColorName.primaryColor,
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
