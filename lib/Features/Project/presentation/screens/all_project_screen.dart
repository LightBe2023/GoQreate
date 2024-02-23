import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_qreate_teams/Common/colors.dart';
import 'package:go_qreate_teams/Features/Home/presentation/screens/home_screen.dart';
import 'package:go_qreate_teams/Features/Home/presentation/widgets/project_cards_widget.dart';
import 'package:go_qreate_teams/Features/Project/presentation/screens/project_details_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AllProjectScreen extends StatefulWidget {
  const AllProjectScreen({super.key});

  @override
  State<AllProjectScreen> createState() => _AllProjectScreenState();
}

class _AllProjectScreenState extends State<AllProjectScreen> {

  List<ProjectCard> projectCards = [];
  late SharedPreferences prefs;

  @override
  void initState() {
    getCurrentUser();
    super.initState();
  }

  Future<void> getCurrentUser() async {
    prefs = await SharedPreferences.getInstance();

    fetchProjectData();
  }

  Future<void> fetchProjectData() async {
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

      setState(() {});
    } catch (e) {
      print("Error fetching data: $e");
    }
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
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          },
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 14,
            color: Colors.black,
          ),
        ),
        title: Text(
          'All Projects',
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
          padding: const EdgeInsets.all(15),
          child: ListView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: projectCards.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  // Handle the tap for the specific item (index) here
                  // Pass the document ID of the selected project to ProjectDetailsScreen
                  String projectId = projectCards[index].projectId;
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ProjectDetailsScreen(projectId: projectId),
                    ),
                  );
                },
                onLongPress: () {
                  // Show dialog for deleting the project
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Delete Project'),
                        content: const Text('Are you sure you want to delete this project?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(); // Close the dialog
                            },
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () async {
                              // Delete the project document from Firestore
                              await FirebaseFirestore.instance
                                  .collection('projects')
                                  .doc(projectCards[index].projectId)
                                  .delete();

                              // Delete the associated member documents
                              QuerySnapshot<Map<String, dynamic>> memberSnapshot = await FirebaseFirestore.instance
                                  .collection('projects')
                                  .doc(projectCards[index].projectId)
                                  .collection('members')
                                  .get();

                              for (QueryDocumentSnapshot<Map<String, dynamic>> memberDoc in memberSnapshot.docs) {
                                await memberDoc.reference.delete();
                              }

                              // Remove the project from the UI
                              setState(() {
                                projectCards.removeAt(index);
                              });

                              Navigator.of(context).pop(); // Close the dialog
                            },

                            child: const Text('Delete'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: projectCards[index],
              );
            },
          ),
        ),
      ),
    );
  }
}

