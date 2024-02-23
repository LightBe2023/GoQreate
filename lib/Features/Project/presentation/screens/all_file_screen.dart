import 'dart:io';

import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_qreate_teams/Common/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class AllFileScreen extends StatefulWidget {
  final List<String?> selectedFiles;

  const AllFileScreen({
    super.key,
    required this.selectedFiles,
  });

  @override
  State<AllFileScreen> createState() => _AllFileScreenState();
}

class _AllFileScreenState extends State<AllFileScreen> {
  late Future<void>? _shareFilesFuture;

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
      body: Padding(
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
              return GridView.count(
                crossAxisCount: 3,
                children: List.generate(
                  widget.selectedFiles.length,
                      (index) {
                    final fileUrl = widget.selectedFiles[index];
                    return fileUrl != null
                        ? GestureDetector(
                      onTap: () {
                        // Handle file tap
                      },
                      child: Card(
                        elevation: 1,
                        child: SizedBox(
                          height: 95,
                          width: 62,
                          child: _buildImage(fileUrl),
                        ),
                      ),
                    )
                        : SizedBox.shrink();
                  },
                ),
              );
            }
          },
        ),
      ),
    );
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

