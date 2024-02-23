import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_qreate_teams/Common/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluttertoast/fluttertoast.dart';

class FileScreen extends StatefulWidget {
  final void Function(List<String?> filePaths) onFileSelected;
  final List<String?> selectedFiles;

  const FileScreen({super.key, required this.onFileSelected, required this.selectedFiles});

  @override
  State<FileScreen> createState() => _FileScreenState();
}

class _FileScreenState extends State<FileScreen> {
  List<List<String?>> selectedFilesRows = [List.filled(4, null)];

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
              padding: const EdgeInsets.only(right: 20),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    selectedFilesRows.add(List.filled(4, null));
                  });
                },
                child: Icon(
                  Icons.add,
                  color: Colors.black,
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
        body: Column(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: selectedFilesRows.map((row) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (index) {
                    if (index < row.length) {
                      String? filePath = row.elementAt(index);
                      return GestureDetector(
                        onTap: () async {
                          final pickedFiles = await ImagePicker().pickMultiImage();
                          if (pickedFiles.isNotEmpty) {
                            final List<String?> newFilePaths =
                            pickedFiles.map((pickedFile) => pickedFile.path).toList();
                            final totalImages = selectedFilesRows
                                .expand((row) => row)
                                .where((filePath) => filePath != null)
                                .length;
                            if (totalImages + newFilePaths.length > selectedFilesRows.length * 4) {
                              Fluttertoast.showToast(
                                msg: "Cannot select more images than available cards",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                              );
                            } else {
                              setState(() {
                                // Update each index with the corresponding file path
                                for (int i = 0; i < newFilePaths.length; i++) {
                                  if (index + i < row.length) {
                                    row[index + i] = newFilePaths[i];
                                  } else {
                                    row.add(newFilePaths[i]);
                                  }
                                }
                              });
                              // Notify the callback in the parent screen with the first selected file path
                              widget.onFileSelected(newFilePaths);
                            }
                          }
                        },
                        child: Card(
                          elevation: 1,
                          child: SizedBox(
                            height: 100.2,
                            width: 72.29,
                            child: filePath != null
                                ? Image.file(
                              File(filePath),
                              fit: BoxFit.cover,
                            )
                                : const Icon(
                              Icons.add,
                              size: 14,
                              color: ColorName.primaryColor,
                            ),
                          ),
                        ),
                      );
                    } else {
                      return const SizedBox(
                        height: 100.2,
                        width: 72.29,
                      );
                    }
                  }),
                );

              }).toList(),
            ),
            Expanded(
              child: Container(),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              child: ElevatedButton(
                onPressed: () {
                  /// save images to shared preferences
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
    );
  }
}
