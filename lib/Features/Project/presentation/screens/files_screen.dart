import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_qreate_teams/Common/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FileScreen extends StatefulWidget {
  const FileScreen({Key? key}) : super(key: key);

  @override
  State<FileScreen> createState() => _FileScreenState();
}

class _FileScreenState extends State<FileScreen> {
  List<String?> selectedFiles = [];

  @override
  void initState() {
    _loadFilePathsFromSharedPreferences();
    super.initState();
  }

  void _loadFilePathsFromSharedPreferences() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String>? filePaths = prefs.getStringList('filePaths');
      if (filePaths != null) {
        setState(() {
          selectedFiles.addAll(filePaths);
          print("file paths: " + selectedFiles.toString());
        });
      }
    } catch (e) {
      print("Error loading file paths: $e");
    }
  }

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
          'Files',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: ColorName.primaryColor,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20, top: 15),
            child: GestureDetector(
              onTap: () {
                _deleteFilePathsToSharedPreferences();
              },
              child: Text(
                'Reset',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                  color: Colors.black.withOpacity(0.5),
                ),
              ),
            ),
          ),
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
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 0.7,
          ),
          itemCount: selectedFiles.length + 1, // Plus one for the "Add" button
          itemBuilder: (context, index) {
            if (index < selectedFiles.length) {
              return GestureDetector(
                onTap: () {
                  // Handle tap on file
                },
                child: Card(
                  elevation: 1,
                  child: Image.file(
                    File(selectedFiles[index]!),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            } else {
              return GestureDetector(
                onTap: () async {
                  final pickedFiles = await ImagePicker().pickMultiImage();
                  if (pickedFiles.isNotEmpty) {
                    final List<String?> newFilePaths =
                    pickedFiles.map((pickedFile) => pickedFile.path).toList();
                    setState(() {
                      selectedFiles.addAll(newFilePaths.where((path) => path != null));
                    });
                    _saveFilePathsToSharedPreferences(newFilePaths);
                  }
                },
                child: const Card(
                  elevation: 1,
                  child: Icon(
                    Icons.add,
                    size: 14,
                    color: ColorName.primaryColor,
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  void _deleteFilePathsToSharedPreferences() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('filePaths'); // Remove the 'filePaths' key from SharedPreferences
      setState(() {
        selectedFiles.clear(); // Clear the selectedFiles list
      });
    } catch (e) {
      print("Error deleting file paths: $e");
    }
  }

  void _saveFilePathsToSharedPreferences(List<String?> filePaths) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> currentFilePaths = prefs.getStringList('filePaths') ?? [];
      currentFilePaths.addAll(filePaths.where((path) => path != null).cast<String>());
      await prefs.setStringList('filePaths', currentFilePaths);
    } catch (e) {
      print("Error saving file paths: $e");
    }
  }
}
