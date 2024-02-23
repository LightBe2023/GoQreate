import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:go_qreate_teams/Common/colors.dart';
import 'package:go_qreate_teams/Features/Login/presentation/screens/login_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  File? _image;

  final picker = ImagePicker();

  late SharedPreferences prefs;

  String _name = '';
  String _userName = '';

  bool _editMode = false;

  @override
  void initState() {
    initializePreferences();

    super.initState();
  }

  Future<void> initializePreferences() async {
    prefs = await SharedPreferences.getInstance();

    getUserData();
  }

  Future<void> getUserData() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: prefs.getString('userEmail'))
        .get();

    if (snapshot.docs.isNotEmpty) {
      final userData = snapshot.docs.first.data();
      setState(() {
        _nameController.text = userData['name'] ?? '';
        _userNameController.text = userData['userName'] ?? '';
        _emailController.text = userData['email'] ?? '';
        _passwordController.text = userData['password'] ?? '';
        _name = userData['name'] ?? '';
        _userName = userData['userName'] ?? '';

        final profileImage = userData['profileImage'] ?? ''; // Get profileImage URL
        if (profileImage.isNotEmpty) {
          // If profileImage URL is not empty, load the image
          _image = File(profileImage);
        }
      });
    }
  }

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> _uploadImage() async {
    if (_image != null) {
      try {
        final userEmail = prefs.getString('userEmail');
        final userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: userEmail)
            .get();

        if (userSnapshot.docs.isNotEmpty) {
          final userId = userSnapshot.docs.first.id;
          final ref =
          FirebaseStorage.instance.ref().child('user_images/$userId');
          await ref.putFile(_image!);
          final url = await ref.getDownloadURL();

          // Update fields in Firestore
          final userData = {
            'profileImage': url,
            'name': _nameController.text,
            'userName': _userNameController.text,
            'email': _emailController.text,
            'password': _passwordController.text,
          };

          // If password is edited, update confirm password and ensure they match
          if (_passwordController.text != _confirmPasswordController.text) {
            userData['confirmPassword'] = _passwordController.text;
          }

          // Update Firestore document
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .update(userData);

          // Update userEmail and userName in SharedPreferences
          prefs.setString('userEmail', _emailController.text);
          prefs.setString('userName', _userNameController.text);

          // Update local variables with new values
          setState(() {
            _name = _nameController.text;
            _userName = _userNameController.text;
          });
        } else {
          print('User not found');
        }
      } catch (error) {
        print('Error uploading image: $error');
      }
    }
  }

  Future<void> logout() async {
    await prefs.setBool('isLoggedIn', false);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 50, left: 15, right: 15, bottom: 10),
        child: SingleChildScrollView(
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  logout();
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Logout',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.red
                      ),
                    ),
                    const SizedBox(width: 5,),
                    const Icon(
                      Icons.logout,
                      size: 20,
                      color: Colors.red,
                    )
                  ],
                ),
              ),
              Stack(
                children: [
                  SizedBox(
                    width: 100, // Adjust width as needed
                    height: 100, // Adjust height as needed
                    child: ClipOval(
                      child: _image == null
                          ? Image.asset(
                        'assets/icons/profile_black.png',
                        fit: BoxFit.contain,
                      )
                          : _image!.path.startsWith('http') // Check if _image path starts with 'http' indicating it's a URL
                          ? Image.network(
                        _image!.path, // Use _image path directly
                        fit: BoxFit.cover,
                      )
                          : Image.file(
                        _image!, // Use _image directly
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.blue,
                      child: IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white),
                        onPressed: () {
                          if (_editMode) {
                            getImage();
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              Text(
                _name.isNotEmpty ? _name : 'Name',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                _userName.isNotEmpty ? _userName : 'username',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    if (_editMode) {
                      // Save changes
                      _uploadImage(); // Call _uploadImage method when in edit mode
                    }
                    _editMode = !_editMode; // Toggle edit mode
                  });
                },
                style: ElevatedButton.styleFrom(
                  primary: _editMode ? Colors.green : Colors.black.withOpacity(0.5),
                  padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  _editMode ? 'Save' : 'Edit Profile',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 30,),
              TextFormField(
                enabled: _editMode,
                controller: _nameController,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(16.0),
                  filled: true, // Enable background filling
                  fillColor: Colors.white, // Set the background color
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.black12), // Border color
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.black12), // Border color
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.black12), // Border color
                  ),
                  prefixIcon: Image.asset(
                    'assets/icons/person_icon.jpg', // Replace with your asset path
                    width: 20.0, // Adjust the width as needed
                    height: 20.0, // Adjust the height as needed
                  ),
                  hintText: 'Name',
                  hintStyle: GoogleFonts.poppins(
                    fontWeight: FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Name is required.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15,),
              TextFormField(
                enabled: _editMode,
                controller: _userNameController,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(16.0),
                  filled: true, // Enable background filling
                  fillColor: Colors.white, // Set the background color
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.black12), // Border color
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.black12), // Border color
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.black12), // Border color
                  ),
                  prefixIcon: Image.asset(
                    'assets/icons/person_icon.jpg', // Replace with your asset path
                    width: 20.0, // Adjust the width as needed
                    height: 20.0, // Adjust the height as needed
                  ),
                  hintText: 'User Name',
                  hintStyle: GoogleFonts.poppins(
                    fontWeight: FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'User Name is required.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15,),
              TextFormField(
                enabled: _editMode,
                controller: _emailController,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(16.0),
                  filled: true, // Enable background filling
                  fillColor: Colors.white, // Set the background color
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.black12), // Border color
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.black12), // Border color
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.black12), // Border color
                  ),
                  prefixIcon: Image.asset(
                    'assets/icons/email_icon.jpg', // Replace with your asset path
                    width: 20.0, // Adjust the width as needed
                    height: 20.0, // Adjust the height as needed
                  ),
                  hintText: 'Email',
                  hintStyle: GoogleFonts.poppins(
                    fontWeight: FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email is required.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15,),
              TextFormField(
                enabled: _editMode,
                obscureText: true,
                controller: _passwordController,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(16.0),
                  filled: true, // Enable background filling
                  fillColor: Colors.white, // Set the background color
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.black12), // Border color
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.black12), // Border color
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.black12), // Border color
                  ),
                  prefixIcon: Image.asset(
                    'assets/icons/key_icon.jpg', // Replace with your asset path
                    width: 20.0, // Adjust the width as needed
                    height: 20.0, // Adjust the height as needed
                  ),
                  hintText: 'Password',
                  hintStyle: GoogleFonts.poppins(
                    fontWeight: FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password is required.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15,),
              TextFormField(
                enabled: _editMode,
                obscureText: true,
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(16.0),
                  filled: true, // Enable background filling
                  fillColor: Colors.white, // Set the background color
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.black12), // Border color
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.black12), // Border color
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.black12), // Border color
                  ),
                  prefixIcon: Image.asset(
                    'assets/icons/key_icon.jpg', // Replace with your asset path
                    width: 20.0, // Adjust the width as needed
                    height: 20.0, // Adjust the height as needed
                  ),
                  suffixIcon: Image.asset(
                    'assets/icons/eye-slash.jpg', // Replace with your asset path
                    width: 20.0, // Adjust the width as needed
                    height: 20.0, // Adjust the height as needed
                  ),
                  hintText: 'Confirm Password',
                  hintStyle: GoogleFonts.poppins(
                    fontWeight: FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Confirm Password is required.';
                  } else if (value != _passwordController.text) {
                    return 'Passwords do not match.';
                  }
                  return null;
                },
              ),

              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 20),
              //   child: SizedBox(
              //     width: double.infinity,
              //     height: 50,
              //     child: ElevatedButton(
              //       onPressed: () {
              //         // if (_formKey.currentState!.validate()) {
              //         //   _signUp();
              //         // }
              //       },
              //       style: ElevatedButton.styleFrom(
              //         primary: Colors.white, // Button color
              //         shape: RoundedRectangleBorder(
              //           borderRadius: BorderRadius.circular(10.0), // Border radius
              //         ),
              //         side: BorderSide(width: 1, color: Colors.black.withOpacity(0.1)), // Add stroke
              //         elevation: 0,
              //       ),
              //       child: const Padding(
              //         padding: EdgeInsets.all(12.0),
              //         child: Text(
              //           'Sign Out',
              //           style: TextStyle(
              //             color: Colors.red, // Text color
              //             fontSize: 16.0, // Text size
              //           ),
              //         ),
              //       ),
              //     ),
              //   ),
              // ),

            ],
          ),
        ),
      )
    );
  }
}
