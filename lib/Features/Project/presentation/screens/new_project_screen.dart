import 'dart:io';

import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_qreate_teams/Common/colors.dart';
import 'package:go_qreate_teams/Common/dynamic_text_box_list.dart';
import 'package:go_qreate_teams/Features/Home/presentation/screens/home_screen.dart';
import 'package:go_qreate_teams/Features/Project/presentation/screens/files_screen.dart';
import 'package:go_qreate_teams/Features/Project/presentation/screens/project_details_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NewProjectScreen extends StatefulWidget {
  const NewProjectScreen({super.key});

  @override
  State<NewProjectScreen> createState() => _NewProjectScreenState();
}

class _NewProjectScreenState extends State<NewProjectScreen> {
  DateTime? selectedDate;
  List<DateTime>? _dates = [];

  List<String?> milestones = [];

  final TextEditingController titleController = TextEditingController();
  final TextEditingController purposeController = TextEditingController();
  final TextEditingController detailsController = TextEditingController();
  final TextEditingController budgetController = TextEditingController();

  late SharedPreferences prefs;
  List<String?> selectedFiles = List.filled(4, null);
  late Future<void> _saveProjectFuture;

  @override
  initState() {
    getCurrentUser();
    _saveProjectFuture = Future.value();
    super.initState();
  }

  Future<void> getCurrentUser() async {
    prefs = await SharedPreferences.getInstance();
  }

  Future<void> calendarDialog() async {
    final List<DateTime?>? selectedDates = await showCalendarDatePicker2Dialog(
      context: context,
      config: CalendarDatePicker2WithActionButtonsConfig(
        calendarType: CalendarDatePicker2Type.range,
        buttonPadding: const EdgeInsets.symmetric(horizontal: 20),
        okButton: const Padding(
          padding: EdgeInsets.only(right: 20),
          child: Text('OK',
              style: TextStyle(
                  color: Colors.black87, fontWeight: FontWeight.w600)),
        ),
        cancelButton: const Padding(
          padding: EdgeInsets.only(right: 20),
          child: Text('CANCEL',
              style: TextStyle(
                  color: Colors.black54, fontWeight: FontWeight.w600)),
        ),
      ),
      dialogSize: const Size(325, 400),
      value: _dates!,
      borderRadius: BorderRadius.circular(8),
    );

    if (selectedDates != null && selectedDates.length == 2) {
      setState(() {
        _dates = selectedDates.cast<DateTime>();
      });
    }
  }

  // Callback function to receive the selected file path
  // Callback function to receive the selected file paths
  void _onFileSelected(List<String?> filePaths) {
    setState(() {
      selectedFiles = filePaths;
    });
  }


  Future<String?> uploadFile(File file) async {
    try {
      // Generate a unique filename for each uploaded file
      String fileName = DateTime.now().millisecondsSinceEpoch.toString() +
          '_' +
          file.path.split('/').last;

      // Upload file to Firebase Storage
      UploadTask uploadTask = FirebaseStorage.instance
          .ref()
          .child('go-qreate-teams.appspot.com/$fileName')
          .putFile(file);

      // Get download URL after the file is uploaded
      String fileUrl = await (await uploadTask).ref.getDownloadURL();

      return fileUrl;
    } catch (e) {
      print("Error uploading file: $e");
      return null;
    }
  }

  Future<void> _storeData() async {
    // Set the _saveProjectFuture to the result of _saveProject function
    setState(() {
      _saveProjectFuture = _saveProject();
    });
  }


  Future<void> _saveProject() async {
    // Show the loading indicator while saving the project
    try {
      // Show the loading dialog
      showDialog(
        context: context,
        barrierDismissible: false, // Prevent dismissing the dialog by tapping outside
        builder: (BuildContext context) {
          return const AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Creating project...'),
              ],
            ),
          );
        },
      );

      // Save data to Firestore and get the document ID
      DocumentReference<Map<String, dynamic>> docRef = await FirebaseFirestore.instance.collection('projects').add({
        'userName': prefs.getString('userName'),
        'title': titleController.text,
        'purpose': purposeController.text,
        'details': detailsController.text,
        'budget': budgetController.text,
        'start_date': _dates != null && _dates!.isNotEmpty ? _dates![0].toUtc() : null,
        'end_date': _dates != null && _dates!.isNotEmpty ? _dates![1].toUtc() : null,
        'fileUrls': [], // Placeholder for file URLs
        'milestones': List<String?>.from(milestones), // Copy milestones list
        'milestoneStatus': 'pending',
      });

      String projectId = docRef.id; // Get the document ID

      // Upload files and update document with file URLs
      await _uploadFilesAndUpdateUrls(docRef, projectId);

      // Close the loading dialog
      Navigator.of(context).pop();

      // Navigate to the project details screen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ProjectDetailsScreen(projectId: projectId), // Pass the document ID
        ),
      );

    } catch (e) {
      // Handle error
      print("Error storing data: $e");
      // Close the loading dialog in case of an error
      Navigator.of(context).pop();
    }
  }

  Future<void> _uploadFilesAndUpdateUrls(DocumentReference<Map<String, dynamic>> docRef, String projectId) async {
    try {
      List<String?> fileUrls = [];

      // Upload files and get URLs
      for (String? filePath in selectedFiles) {
        if (filePath != null) {
          File file = File(filePath);
          String? fileUrl = await uploadFile(file);
          fileUrls.add(fileUrl);
        }
      }

      // Update the document with file URLs
      await docRef.update({'fileUrls': fileUrls});

    } catch (e) {
      // Handle error
      print("Error uploading files and updating URLs: $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: () async {
        // Show a dialog to confirm whether the user wants to discard the project creation
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Discard Project Creation?'),
            content: const Text('Are you sure you want to discard the project creation?'),
            actions: [
              TextButton(
                onPressed: () {
                  // Pop the dialog and stay on the current screen
                  Navigator.pop(context, false);
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  // Pop the dialog and navigate back to the previous screen
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                  );
                },
                child: const Text('Discard'),
              ),
            ],
          ),
        );
      },
      child: Scaffold(
        appBar: AppBar(
          leading: GestureDetector(
            onTap: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            },
            child: InkWell(
              onTap: () async {
                bool discard = await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Discard Project Creation?'),
                    content: const Text('Are you sure you want to discard the project creation?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          // Pop the dialog and stay on the current screen
                          Navigator.pop(context, false);
                        },
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          // Pop the dialog and navigate back to the previous screen
                          Navigator.pop(context, true);
                        },
                        child: const Text('Discard'),
                      ),
                    ],
                  ),
                );

                if (discard ?? false) {
                  // If the user chooses to discard, navigate back to the previous screen
                  Navigator.of(context).pop();
                }
              },
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 14,
                color: Colors.black,
              ),
            ),
          ),
          title: Text(
            'New Project',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: ColorName.primaryColor,
            ),
          ),
          centerTitle: true,
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
            padding: const EdgeInsets.only(top: 10, bottom: 20, left: 20, right: 20),
            child: Column(
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.transparent,
                    hintText: 'Project Title',
                    hintStyle: GoogleFonts.poppins(
                      fontWeight: FontWeight.normal,
                      fontSize: 16,
                    ),
                    contentPadding: EdgeInsets.zero,
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.withOpacity(0.5),
                        width: 0.5,
                      ),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: ColorName.primaryColor,
                        width: 2.0,
                      ),
                    ),
                  ),
                ),
      
                TextFormField(
                  controller: purposeController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.transparent,
                    hintText: 'Purpose',
                    hintStyle: GoogleFonts.poppins(
                      fontWeight: FontWeight.normal,
                      fontSize: 16,
                    ),
                    contentPadding: EdgeInsets.zero,
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.withOpacity(0.5),
                        width: 0.5,
                      ),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: ColorName.primaryColor,
                        width: 2.0,
                      ),
                    ),
                  ),
                ),
      
                const SizedBox(height: 50,),
      
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => calendarDialog(),
                      child: Text.rich(
                        TextSpan(
                          children: [
                            const TextSpan(
                              text: 'Select dates: ',
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 12,
                                color: ColorName.primaryColor,
                              ),
                            ),
                            if (_dates!.isNotEmpty)
                              TextSpan(
                                text:
                                '${DateFormat('MMM d, yyyy').format(_dates![0])} - ${DateFormat('MMM d, yyyy').format(_dates![1])}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                  color: Colors.black,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
      
                const SizedBox(height: 25,),
      
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
                    controller: detailsController,
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
      
                const SizedBox(height: 40,),
      
                GestureDetector(
                  onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => FileScreen(
                            onFileSelected: _onFileSelected,
                            selectedFiles: selectedFiles,
                          ),
                        ),
                      );
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
                    child: const Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Row(
                        children: [
                          Icon(
                            Icons.add_circle_outline_rounded,
                            color: ColorName.primaryColor,
                            size: 27,
                          ),
                          SizedBox(width: 7,),
                          Text(
                            'Attachments',
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 14,
                              color: ColorName.primaryColor,
                            ),
                            textAlign: TextAlign.start,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
      
                const SizedBox(height: 15,),
      
                const SizedBox(
                  width: double.infinity,
                  child: Text(
                    'Milestones',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                      color: Color(0xff6A6A6A),
                    ),
                    textAlign: TextAlign.start,
                  ),
                ),
      
                const SizedBox(height: 5,),
      
                DynamicTextBoxList(
                  onValuesChanged: (values) {
                    setState(() {
                      milestones = values;
                    });
                  },
                ),
      
                const SizedBox(height: 15,),
      
                // Row(
                //   children: [
                //     SizedBox(
                //       width: screenWidth / 2,
                //       height: 19,
                //       child: Row(
                //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //         children: [
                //           const Padding(
                //             padding: EdgeInsets.only(left: 5, right: 20),
                //             child: Text(
                //               'Budget',
                //               style: TextStyle(
                //                 fontWeight: FontWeight.w400,
                //                 fontSize: 16,
                //                 color: Color(0xff6A6A6A),
                //               ),
                //               textAlign: TextAlign.start,
                //             ),
                //           ),
                //           Expanded(
                //             child: Container(
                //               height: 40,
                //               decoration: BoxDecoration(
                //                 color: Colors.white,
                //                 borderRadius: BorderRadius.circular(6),
                //                 boxShadow: [
                //                   BoxShadow(
                //                     color: Colors.grey.withOpacity(0.5),
                //                     spreadRadius: 0.1,
                //                     blurRadius: 3,
                //                     offset: const Offset(0, 1),
                //                   ),
                //                 ],
                //               ),
                //               child: TextFormField(
                //                 controller: budgetController,
                //                 maxLines: null,
                //                 decoration: const InputDecoration(
                //                     border: InputBorder.none,
                //                     contentPadding: EdgeInsets.only(left: 10, bottom: 17)
                //                 ),
                //                 style: const TextStyle(
                //                   fontWeight: FontWeight.w400,
                //                   fontSize: 12,
                //                   height: 0,
                //                   color: Colors.black,
                //                 ),
                //               ),
                //             ),
                //           ),
                //         ],
                //       ),
                //     ),
                //   ],
                // ),
      
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                  child: ElevatedButton(
                    onPressed: () {
                      _storeData();
                    },
                    style: ElevatedButton.styleFrom(
                      primary: ColorName.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      minimumSize: Size(double.infinity, 54.0),
                    ),
                    child: const Text(
                      'Start',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
