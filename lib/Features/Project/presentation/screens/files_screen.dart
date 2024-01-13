import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:go_qreate_teams/Common/colors.dart';
import 'package:google_fonts/google_fonts.dart';

class FileScreen extends StatefulWidget {
  final void Function(String? filePath) onFileSelected;

  const FileScreen({super.key, required this.onFileSelected});

  @override
  State<FileScreen> createState() => _FileScreenState();
}

class _FileScreenState extends State<FileScreen> {
  List<String?> selectedFiles = List.filled(4, null);

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
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.dark,
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          4, // Number of cards
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
                  widget.onFileSelected(filePath);
                }
              },
              child: Card(
                elevation: 1,
                child: SizedBox(
                  height: 100.2,
                  width: 72.29,
                  child: selectedFiles[index] != null
                      ? Image.file(
                    // Use the selected file as the cover photo
                    File(selectedFiles[index]!),
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
    );
  }
}
