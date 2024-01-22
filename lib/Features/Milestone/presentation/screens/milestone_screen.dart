import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_qreate_teams/Common/colors.dart';
import 'package:go_qreate_teams/Common/swipe_to_delete.dart';
import 'package:go_qreate_teams/Features/Project/presentation/screens/project_details_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class MilestoneScreen extends StatefulWidget {
  late List milestones;
  late String projectId;
  late String milestoneStatus;
  late String title;
  late String details;
  late DateTime? startDate;

  MilestoneScreen({
    super.key,
    required this.milestones,
    required this.projectId,
    required this.milestoneStatus,
    required this.title,
    required this.details,
    required this.startDate,
  });

  @override
  State<MilestoneScreen> createState() => _MilestoneScreenState();
}

class _MilestoneScreenState extends State<MilestoneScreen> {
  final TextEditingController milestoneController = TextEditingController();

  bool isArrowDown = false;
  bool isDeleted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
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
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 20),
            child: Icon(
              Icons.add,
              size: 20,
              color: Colors.black,
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
            // if (widget.milestoneStatus.contains('approved')) ...[
            //   if (isDeleted == false) ...[
            //     Container(
            //       width: double.infinity,
            //       decoration: BoxDecoration(
            //         color: Colors.white,
            //         borderRadius: BorderRadius.circular(6), // Adjust the radius for curved edges
            //       ),
            //       child: Padding(
            //         padding: const EdgeInsets.all(5),
            //         child: Row(
            //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //           children: [
            //             Expanded(
            //               child: Column(
            //                 crossAxisAlignment: CrossAxisAlignment.start,
            //                 children: [
            //                   Text(
            //                     widget.title,
            //                     style: GoogleFonts.poppins(
            //                         fontWeight: FontWeight.w500,
            //                         fontSize: 12,
            //                         color: Colors.black
            //                     ),
            //                   ),
            //                   Text(
            //                     widget.details,
            //                     style: GoogleFonts.poppins(
            //                         fontWeight: FontWeight.w400,
            //                         fontSize: 7,
            //                         color: Colors.grey
            //                     ),
            //                   ),
            //                 ],
            //               ),
            //             ),
            //             const SizedBox(width: 10,),
            //             Column(
            //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //               children: [
            //                 Text(
            //                   DateFormat('dd MMM').format(widget.startDate!),
            //                   style: GoogleFonts.poppins(
            //                     fontWeight: FontWeight.w500,
            //                     fontSize: 10,
            //                     color: Colors.black,
            //                   ),
            //                 ),
            //                 const SizedBox(height: 15,),
            //                 const Icon(
            //                   Icons.star_border,
            //                   size: 17,
            //                   color: Colors.grey,
            //                 )
            //               ],
            //             ),
            //             const SizedBox(width: 10,),
            //             GestureDetector(
            //               onTap: () {
            //                 setState(() {
            //                   isDeleted = true;
            //                 });
            //               },
            //               child: Container(
            //                 decoration: BoxDecoration(
            //                   color: ColorName.primaryColor,
            //                   borderRadius: BorderRadius.circular(4),
            //                 ),
            //                 child: Center(
            //                     child: Padding(
            //                       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            //                       child: Image.asset(
            //                         'assets/icons/delete_icon.png',
            //                         fit: BoxFit.contain,
            //                         height: 18,
            //                       ),
            //                     )
            //                 ),
            //               ),
            //             ),
            //           ],
            //         ),
            //       ),
            //     ),
            //   ]
            // ],
            if (!isDeleted) ...[
              SwipeToDelete(
                milestones: widget.milestones,
                onDelete: (isDeleted) {
                  setState(() {
                    this.isDeleted = isDeleted;

                    print('bleee: '+this.isDeleted.toString());
                  });
                },
              ),
              if (!isArrowDown) ...[
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isArrowDown = true;
                    });
                  },
                  child: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 30,
                  ),
                ),
              ],
              if (isArrowDown) ...[
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isArrowDown = false;
                    });
                  },
                  child: const Icon(
                    Icons.keyboard_arrow_up_rounded,
                    size: 30,
                  ),
                ),
              ],
              if (isArrowDown) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        _updateMilestone('revision');
                      },
                      child: Container(
                        width: 63,
                        height: 26,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: ColorName.primaryColor,
                            width: 1, // Set the width of the stroke
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            'Revision', // Add your text here
                            style: TextStyle(
                              color: ColorName.primaryColor,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20,),
                    GestureDetector(
                      onTap: () {
                        _updateMilestone('approved');
                      },
                      child: Container(
                        width: 63,
                        height: 26,
                        decoration: BoxDecoration(
                          color: ColorName.primaryColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Center(
                          child: Text(
                            'Approve', // Add your text here
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ]
            ]
          ],
        ),
      ),
    );
  }

  Future<void> _updateMilestone(String status) async {
    try {

      // Get the document reference for the specified projectId
      DocumentReference<Map<String, dynamic>> projectRef =
      FirebaseFirestore.instance.collection('projects').doc(widget.projectId);

// Check if the document exists
      DocumentSnapshot<Map<String, dynamic>> projectSnapshot = await projectRef.get();

      if (projectSnapshot.exists) {
        // If the document exists, update the 'milestoneStatus' field
        await projectRef.update({'milestoneStatus': status});

      }

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const ProjectDetailsScreen(),
        ),
      );

      // You can also handle attachments, milestones, and other data in a similar way
    } catch (e) {
      print("Error storing data: $e");
    }
  }
}
