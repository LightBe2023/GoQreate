import 'dart:io';

import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_qreate_teams/Common/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class AllFileScreen extends StatefulWidget {
  final List<String?> selectedFiles;
  final String projectId;

  const AllFileScreen({
    super.key,
    required this.selectedFiles,
    required this.projectId,
  });

  @override
  State<AllFileScreen> createState() => _AllFileScreenState();
}

class _AllFileScreenState extends State<AllFileScreen> {
  late Future<void>? _shareFilesFuture;
  List<String?> newFilePaths = [];

  @override
  void initState() {
    super.initState();
    _shareFilesFuture = null;
  }

  Future<void> _shareFiles() async {
    try {
      // Create a temporary directory to store the compressed file
      Directory tempDir = await getTemporaryDirectory();
      String tempPath = tempDir.path;

      // Generate a unique name for the zip file
      String zipFileName = 'selected_files.zip';

      // Path of the zip file
      String zipFilePath = '$tempPath/$zipFileName';

      // Create a new zip file
      Archive archive = Archive();

      // Add selected files to the zip archive
      for (String? fileUrl in widget.selectedFiles) {
        if (fileUrl != null) {
          // Fetch the file content
          List<int> bytes = await _fetchFileContent(fileUrl);
          if (bytes.isNotEmpty) {
            // Extract the file name from the URL
            String fileName = fileUrl.split('/').last;

            // Remove the string after .jpeg
            fileName = fileName.split('.jpeg').first + '.jpeg';

            // Sanitize the file name
            fileName = fileName.replaceAll('%', '_').replaceAll('?', '_').replaceAll('=', '_');

            // Add the file with the sanitized name to the archive
            archive.addFile(ArchiveFile(fileName, bytes.length, bytes));
          }
        }
      }

      // Check if the archive is empty
      if (archive.isEmpty) {
        throw Exception('No files to compress');
      }

      // Save the zip file to disk
      final zipData = ZipEncoder().encode(archive);
      File(zipFilePath).writeAsBytesSync(zipData!);

      // Share the zip file
      await Share.shareFiles(
        [zipFilePath],
        text: 'Sharing selected files',
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error compressing and sharing files: $e');
      }
    }
    await Future.delayed(const Duration(seconds: 2));
  }

  Future<List<int>> _fetchFileContent(String fileUrl) async {
    try {
      // Fetch the file content (replace this with your own logic to fetch the file)
      HttpClientRequest request = await HttpClient().getUrl(Uri.parse(fileUrl));
      HttpClientResponse response = await request.close();
      List<int> bytes = await consolidateHttpClientResponseBytes(response);
      return bytes;
    } catch (e) {
      print('Error fetching file content: $e');
      return [];
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 14,
            color: Colors.black,
          ),
        ),
        title: Text(
          'All Files',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: ColorName.primaryColor,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: IconButton(
              icon: const Icon(
                Icons.share_rounded,
                color: Colors.black,
              ),
              onPressed: () async {
                setState(() {
                  _shareFilesFuture = _shareFiles();
                });
              },
            ),
          )
        ],
        centerTitle: true,
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.dark,
        ),
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: FutureBuilder(
                future: _shareFilesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // While the future is executing, show a loading indicator
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Preparing files...'),
                        ],
                      ),
                    );
                  } else if (snapshot.hasError) {
                    // If an error occurs, display an error message
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  } else {
                    // If the future completes successfully, display the grid view
                    return GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 0.9,
                      ),
                      itemCount: widget.selectedFiles.length + 1, // Plus one for the "Add" button
                      itemBuilder: (context, index) {
                        if (index < widget.selectedFiles.length) {
                          final fileUrl = widget.selectedFiles[index];
                          return GestureDetector(
                            onLongPress: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Delete File'),
                                    content: Text('Are you sure you want to delete this file?'),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          // Delete file from Firestore
                                          await FirebaseFirestore.instance
                                              .collection('projects')
                                              .doc(widget.projectId)
                                              .update({
                                            'fileUrls': FieldValue.arrayRemove([fileUrl]),
                                          });

                                          // Remove file from local list
                                          setState(() {
                                            widget.selectedFiles.removeAt(index);
                                          });

                                          Navigator.of(context).pop(); // Close dialog
                                        },
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      content: SizedBox(
                                        width: 300,
                                        height: 300,
                                        child: _buildImage(fileUrl),
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text('Close'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              child: Card(
                                elevation: 1,
                                child: SizedBox(
                                  height: 95,
                                  width: 62,
                                  child: _buildImage(fileUrl!),
                                ),
                              ),
                            ),
                          );
                        }
                        else {
                          return GestureDetector(
                            onTap: () async {
                              final pickedFiles = await ImagePicker().pickMultiImage();
                              if (pickedFiles.isNotEmpty) {
                                _addFiles(pickedFiles);
                              }
                            },
                            child: Card(
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
                    );

                  }
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            child: ElevatedButton(
              onPressed: () {
                if (newFilePaths.isNotEmpty) {
                  _uploadAndSaveFiles(newFilePaths);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorName.primaryColor,
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

  Future<void> _addFiles(List<XFile>? pickedFiles) async {
    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      try {
        setState(() {
          newFilePaths =
              pickedFiles.map((pickedFile) => pickedFile.path).toList();
          widget.selectedFiles.addAll(newFilePaths.where((path) => path != null));
        });
        // await _uploadAndSaveFiles(newFilePaths);
      } catch (e) {
        print("Error adding files: $e");
      }
    }
  }

  Future<void> _uploadAndSaveFiles(List<String?> newFilePaths) async {
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
                Text('Saving files...'),
              ],
            ),
          );
        },
      );

      List<String?> newFileUrls = [];

      // Upload new files and get URLs
      for (String? filePath in newFilePaths) {
        if (filePath != null) {
          File file = File(filePath);
          String? fileUrl = await uploadFile(file);
          if (fileUrl != null) {
            newFileUrls.add(fileUrl);
          }
        }
      }

      // Retrieve existing file URLs from Firestore
      DocumentSnapshot projectDoc = await FirebaseFirestore.instance
          .collection('projects')
          .doc(widget.projectId)
          .get();
      List<String?> existingFileUrls = List<String?>.from(
          (projectDoc.data() as Map<String, dynamic>)['fileUrls'] ?? []);

      // Combine existing and new file URLs
      List<String?> allFileUrls = [];
      allFileUrls.addAll(existingFileUrls);
      allFileUrls.addAll(newFileUrls);

      // Update Firestore with all file URLs
      await FirebaseFirestore.instance
          .collection('projects')
          .doc(widget.projectId)
          .update({'fileUrls': allFileUrls});

      // Dismiss the loading dialog
      Navigator.of(context).pop();

      // Show a toast message indicating successful save
      Fluttertoast.showToast(
        msg: 'Images saved successfully',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    } catch (e) {
      print("Error uploading files and updating URLs: $e");
      // Dismiss the loading dialog in case of an error
      Navigator.of(context).pop();
    }
  }


  // Future<void> _uploadFilesAndUpdateUrls(List<String?> selectedFiles) async {
  //   try {
  //     List<String?> fileUrls = [];
  //
  //     // Upload files and get URLs
  //     for (String? filePath in selectedFiles) {
  //       if (filePath != null) {
  //         File file = File(filePath);
  //         String? fileUrl = await uploadFile(file);
  //         fileUrls.add(fileUrl);
  //       }
  //     }
  //
  //     // Update the Firestore document with file URLs using projectId
  //     await FirebaseFirestore.instance.collection('projects').doc(widget.projectId).update({'fileUrls': fileUrls});
  //
  //   } catch (e) {
  //     // Handle error
  //     print("Error uploading files and updating URLs: $e");
  //   } finally {
  //     // Close the loading dialog
  //     Navigator.of(context).pop();
  //   }
  // }


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


  Widget _buildImage(String fileUrl) {
    return fileUrl.contains('http') || fileUrl.contains('https')
        ? Image.network(
      fileUrl,
      fit: BoxFit.cover,
    )
        : Image.file(
      File(fileUrl),
      fit: BoxFit.cover,
    );
  }
}

