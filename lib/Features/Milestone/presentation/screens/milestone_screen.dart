import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_qreate_teams/Common/colors.dart';
import 'package:go_qreate_teams/Common/swipe_to_delete.dart';
import 'package:go_qreate_teams/Features/Project/presentation/screens/project_details_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class MilestoneScreen extends StatefulWidget {
  final List milestones;
  final String projectId;
  final String title;
  final String details;
  final DateTime? startDate;

  const MilestoneScreen({
    super.key,
    required this.milestones,
    required this.projectId,
    required this.title,
    required this.details,
    required this.startDate,
  });

  @override
  State<MilestoneScreen> createState() => _MilestoneScreenState();
}

class _MilestoneScreenState extends State<MilestoneScreen> {
  final TextEditingController milestoneController = TextEditingController();
  late List<String> editedMilestones;
  late List<String> tempEditedMilestones;

  @override
  void initState() {
    editedMilestones = List.from(widget.milestones);
    tempEditedMilestones = List.from(widget.milestones);

    super.initState();
  }

  void _addEmptyMilestone() {
    setState(() {
      editedMilestones.add(''); // Add an empty string to the list
      tempEditedMilestones.add(''); // Add an empty string to the temporary list
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return await Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => ProjectDetailsScreen(projectId: widget.projectId)),
        );
      },
      child: Scaffold(
        appBar: AppBar(
          leading: GestureDetector(
            onTap: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => ProjectDetailsScreen(projectId: widget.projectId)),
              );
            },
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 14,
              color: Colors.black,
            ),
          ),
          title: Text(
            'Milestone',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: ColorName.primaryColor,
            ),
          ),
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 20),
              child: GestureDetector(
                onTap: _addEmptyMilestone, // Call the method when add icon is tapped
                child: Icon(
                  Icons.add,
                  size: 20,
                  color: Colors.black,
                ),
              ),
            )
          ],
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarBrightness: Brightness.light,
            statusBarIconBrightness: Brightness.dark,
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        body: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: editedMilestones.length,
                  itemBuilder: (context, index) {
                    final milestone = editedMilestones[index];
                    final bool isRevised = milestone.contains('revised');
                    final bool isApproved = milestone.contains('approved');

                    String isApprovedRevised = '';

                    if (isRevised) {
                        isApprovedRevised = 'revised';
                    } else if (isApproved) {
                        isApprovedRevised = 'approved';
                    }

                    final displayName = milestone.replaceAll(RegExp(r',\s*status:\s*\w+'), '');

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: SwipeToDelete(
                        milestone: displayName,
                        onEdit: (newValue) {
                          tempEditedMilestones[index] = newValue;
                        },
                        onApprove: (index) {
                          _updateMilestoneStatus(index, 'approved');
                        },
                        onRevise: (index) {
                          _updateMilestoneStatus(index, 'revised');
                        },
                        onDelete: (index) {
                          _deleteMilestone(index);
                        },
                        index: index,
                        isApprovedRevised: isApprovedRevised,
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                child: ElevatedButton(
                  onPressed: () {
                    _saveMilestones();
                  },
                  style: ElevatedButton.styleFrom(
                    primary: ColorName.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    minimumSize: Size(double.infinity, 54.0),
                  ),
                  child: const Text(
                    'Save',
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
    );
  }

  void _saveMilestones() async {
    setState(() {
      // Update the main list with the changes from the temporary list
      editedMilestones = List.from(tempEditedMilestones);
    });

    try {
      // Get the document reference for the specified projectId
      DocumentReference<Map<String, dynamic>> projectRef =
      FirebaseFirestore.instance.collection('projects').doc(widget.projectId);

      // Update the milestones field in Firestore
      await projectRef.update({'milestones': editedMilestones});

      // Navigate back to the project details screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => ProjectDetailsScreen(projectId: widget.projectId),
        ),
      );
    } catch (e) {
      print("Error updating milestones: $e");
    }
  }

  void _updateMilestoneStatus(int index, String status) async {
    try {
      // Get the document reference for the specified projectId
      DocumentReference<Map<String, dynamic>> projectRef =
      FirebaseFirestore.instance.collection('projects').doc(widget.projectId);

      // Check if the milestone at the specified index has the status field
      bool statusExists = editedMilestones[index].contains('status');

      if (!statusExists) {
        // If the status field doesn't exist, update the milestone with the status field
        editedMilestones[index] += ',status:$status'; // Update the milestone string
      } else {
        // If the status field already exists, update only the status
        // Extract existing status and update it
        editedMilestones[index] = editedMilestones[index].replaceFirst(RegExp(r'status:\w+'), 'status:$status');
      }

      // Update the milestone in Firestore
      await projectRef.update({
        'milestones': editedMilestones,
      });

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => ProjectDetailsScreen(projectId: widget.projectId),
        ),
      );

      // Update the main list with the changes from the temporary list
      setState(() {
        editedMilestones = List.from(tempEditedMilestones);
      });
    } catch (e) {
      print("Error updating milestone status: $e");
    }
  }


  void _deleteMilestone(int index) async {
    try {
      // Get the document reference for the specified projectId
      DocumentReference<Map<String, dynamic>> projectRef =
      FirebaseFirestore.instance.collection('projects').doc(widget.projectId);

      // Remove the milestone from the list in Firestore
      editedMilestones.removeAt(index);
      await projectRef.update({'milestones': editedMilestones});

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => ProjectDetailsScreen(projectId: widget.projectId),
        ),
      );

      // Update the UI
      // setState(() {
      //   editedMilestones.removeAt(index);
      //   tempEditedMilestones.removeAt(index);
      // });
    } catch (e) {
      print("Error deleting milestone: $e");
    }
  }
}
