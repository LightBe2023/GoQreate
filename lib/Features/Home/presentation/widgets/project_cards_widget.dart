import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_qreate_teams/Common/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class ProjectCard extends StatefulWidget {
  final String title;
  final String details;
  final List<dynamic> members;
  final String projectId;
  final DateTime? startDate;
  final DateTime? endDate;
  final String userName;

  const ProjectCard({
    super.key,
    required this.title,
    required this.details,
    required this.members,
    required this.projectId,
    this.startDate,
    this.endDate,
    required this.userName,
  });

  @override
  _ProjectCardState createState() => _ProjectCardState();
}

class _ProjectCardState extends State<ProjectCard> {
  final TextEditingController searchController = TextEditingController();

  late String _searchedUserName = '';

  double calculateProgressPercentage() {
    DateTime currentDate = DateTime.now();
    DateTime? startDate = widget.startDate;
    DateTime? endDate = widget.endDate;

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

    return SizedBox(
      width: double.infinity,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: screenWidth / 1.5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(5)),
                      child: Container(
                        color: const Color(0xFF0AD3FF),
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: Text(
                            'Office Projects',
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.normal,
                                fontSize: 7,
                                color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10,),
                    Text(
                      widget.title,
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.normal,
                          fontSize: 12,
                          color: Colors.black),
                    ),
                    const SizedBox(height: 5,),
                    Text(
                      widget.details,
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.normal,
                          fontSize: 7,
                          color: Colors.black.withOpacity(0.5)),
                    ),
                    const SizedBox(height: 10,),
                    LinearPercentIndicator(
                      padding: EdgeInsets.zero,
                      barRadius: const Radius.circular(10),
                      width: screenWidth / 1.5,
                      lineHeight: 7,
                      percent: calculateProgressPercentage(),
                      backgroundColor: Colors.black.withOpacity(0.1),
                      progressColor: const Color(0xFF0AD3FF),
                    ),
                    const SizedBox(height: 5,),
                    SizedBox(
                      width: double.infinity,
                      child: Text(
                        '${(calculateProgressPercentage() * 100).toInt()}% Complete',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          fontSize: 7,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  SizedBox(
                    width: screenWidth / 12,
                    height: screenWidth / 3.1,
                    child: Stack(
                      children: [
                        for (int i = 0; i < widget.members.length && i < 4; i++)
                          Positioned(
                            top: i * 20.0,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                border: Border.all(
                                    color: Colors.white, width: 1), // White stroke
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: widget.members[i].toString().contains('http')
                                    ? Image.network(
                                  widget.members[i],
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
                                      widget.members[i][0],
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
                        Positioned(
                          top: 4 * 20.0,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(
                                  color: Colors.white, width: 2), // White stroke
                            ),
                            child: SizedBox(
                              height: 28,
                              width: 28,
                              child: FloatingActionButton(
                                backgroundColor: const Color(0xFF0AD3FF),
                                elevation: 0,
                                onPressed: () {
                                  _showSearchPopup(context, widget.projectId);
                                },
                                child: const Icon(
                                  Icons.add,
                                  size: 15,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${widget.members.length}\nMembers',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.normal,
                      fontSize: 7,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ],
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
                        backgroundColor: ColorName.primaryColor,
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

  void _addMemberToProject(String projectId, String receiverUserName, BuildContext context) async {
    try {
      // Get the project reference
      DocumentReference<Map<String, dynamic>> projectRef =
      FirebaseFirestore.instance.collection('projects').doc(projectId);

      // Check if the user is already a member of the project
      QuerySnapshot<Map<String, dynamic>> existingMembersSnapshot =
      await projectRef.collection('members').where('userName', isEqualTo: receiverUserName).get();

      if (existingMembersSnapshot.docs.isEmpty) {
        // If the user is not already a member, add them to the 'members' subcollection
        await projectRef.collection('members').add({
          'userName': receiverUserName,
          'profileImage': '',
        });

        await FirebaseFirestore.instance.collection('notifications').add({
          'initiatorName': widget.userName,
          'receiverUserName': receiverUserName, // Add receiver's username
          'projectTitle': widget.title, // Assuming projectId represents the title of the project
          'timestamp': FieldValue.serverTimestamp(), // Add server timestamp
        });

        // Perform any additional actions or UI updates if needed

        // Show a success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$receiverUserName added to the project'),
          ),
        );
      } else {
        // Show a message indicating that the user is already a member
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$receiverUserName is already a member of the project'),
          ),
        );
      }
    } catch (e) {
      print('Error adding member to project: $e');
    }
  }


}
