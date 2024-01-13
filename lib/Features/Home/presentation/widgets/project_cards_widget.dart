import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class ProjectCard extends StatelessWidget {
  final String title;
  final String details;

  const ProjectCard({super.key,
    required this.title,
    required this.details,
  });

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
                                color: Colors.white
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10,),
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.normal,
                          fontSize: 12,
                          color: Colors.black
                      ),
                    ),
                    const SizedBox(height: 5,),
                    Text(
                      details,
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.normal,
                          fontSize: 7,
                          color: Colors.black.withOpacity(0.5)
                      ),
                    ),
                    const SizedBox(height: 10,),
                    LinearPercentIndicator(
                      padding: EdgeInsets.zero,
                      barRadius: const Radius.circular(10),
                      width: screenWidth / 1.5,
                      lineHeight: 7,
                      percent: 0.5,
                      backgroundColor: Colors.black.withOpacity(0.1),
                      progressColor: const Color(0xFF0AD3FF),
                    ),
                    const SizedBox(height: 5,),
                    SizedBox(
                      width: double.infinity,
                      child: Text(
                        '50% Complete',
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
                        Positioned(
                          top: 5,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(color: Colors.white, width: 1), // White stroke
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: Image.network(
                                'https://images.unsplash.com/photo-1529665253569-6d01c0eaf7b6?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8Mnx8cHJvZmlsZXxlbnwwfHwwfHw%3D&w=1000&q=80',
                                width: 28,
                                height: 28,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 25,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(color: Colors.white, width: 1), // White stroke
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: Image.network(
                                "https://images.unsplash.com/photo-1518806118471-f28b20a1d79d?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=400&q=80",
                                width: 28,
                                height: 28,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 45,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(color: Colors.white, width: 1), // White stroke
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: Image.network(
                                "https://images.unsplash.com/photo-1470406852800-b97e5d92e2aa?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=750&q=80",
                                width: 28,
                                height: 28,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 65,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(color: Colors.white, width: 1), // White stroke
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: Image.network(
                                "https://images.unsplash.com/photo-1473700216830-7e08d47f858e?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=750&q=80",
                                width: 28,
                                height: 28,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 85,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(color: Colors.white, width: 2), // White stroke
                            ),
                            child: SizedBox(
                              height: 28,
                              width: 28,
                              child: FloatingActionButton(
                                backgroundColor: const Color(0xFF0AD3FF),
                                elevation: 0,
                                onPressed: () {
                                  // Handle FAB click
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
                    '15\nMembers',
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.normal,
                        fontSize: 7,
                        color: Colors.black
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
}