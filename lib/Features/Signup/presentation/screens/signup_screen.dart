import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_qreate_teams/Features/Home/presentation/screens/home_screen.dart';
import 'package:go_qreate_teams/Features/Login/presentation/screens/login_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isObscured = true;

  Future<void> signInWithGoogle() async {
    /// Create instance of the firebase auth and google signin
    FirebaseAuth auth = FirebaseAuth.instance;
    final GoogleSignIn googleSignIn = GoogleSignIn();

    /// Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    /// Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth =
    await googleUser!.authentication;

    /// Create a new credentials
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    /// Sign in the user with the credentials
    final UserCredential userCredential =
    await auth.signInWithCredential(credential);
  }


  Future<void> _signUp() async {
    try {
      if (_formKey.currentState!.validate()) {
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        // Save additional user data to Firestore
        await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
          'userName': _userNameController.text,
          'password': _passwordController.text,
          'email': _emailController.text,
          'name': '',
          'profileImage': '',
          // Add other fields as needed
        });

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);

        // Save the username to shared preferences if needed
        await prefs.setString('userName', _userNameController.text);
        await prefs.setString('userEmail', _emailController.text);

        // Navigate to HomeScreen if sign-up is successful
        if (userCredential.user != null) {
          _goToHomeScreen();
        }

        // TODO: Add additional logic if needed, e.g., navigate to a new screen.
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
      // Handle other FirebaseAuthException cases as needed.
    } catch (e) {
      print(e.toString());
      // Handle other exceptions as needed.
    }
  }

  void _goToHomeScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 60, bottom: 20, left: 20, right: 20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Image.asset(
                    'assets/images/logo_image.png',
                    fit: BoxFit.contain,
                    width: 80,
                  ),
                ),
                const SizedBox(height: 50,),
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    'Create Your Account',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: 20,
                    ),
                  ),
                ),
                // const SizedBox(height: 5,),
                // SizedBox(
                //   width: double.infinity,
                //   child: Text(
                //     'Please Fill Below Details And Enjoy Our App',
                //     style: GoogleFonts.poppins(
                //       fontWeight: FontWeight.normal,
                //       fontSize: 12,
                //     ),
                //   ),
                // ),
                const SizedBox(height: 30,),
                TextFormField(
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
                  obscureText: isObscured,
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
                  obscureText: isObscured,
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
                    suffixIcon: GestureDetector(
                      onTap: () {
                        setState(() {
                          isObscured = !isObscured;
                        });
                      },
                      child: Image.asset(
                        isObscured
                            ? 'assets/icons/eye-slash.jpg'
                            : 'assets/icons/eye-slash.jpg',
                        width: 20.0,
                        height: 20.0,
                      ),
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
                const SizedBox(height: 30,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _signUp();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        primary: const Color(0xFF0AD3FF), // Button color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0), // Border radius
                        ),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Text(
                          'Sign Up',
                          style: TextStyle(
                            color: Colors.white, // Text color
                            fontSize: 16.0, // Text size
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Divider(
                            color: Colors.grey,
                            height: 36,
                            thickness: 1,
                          ),
                        ),
                      ),
                      Text(
                        'Or continue with',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.normal,
                          fontSize: 12,
                        ),
                      ),
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Divider(
                            color: Colors.grey,
                            height: 36,
                            thickness: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        await signInWithGoogle();
                        if (mounted) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const HomeScreen()));
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.white, // Button color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0), // Border radius
                          side: BorderSide(color: Colors.black.withOpacity(0.1)), // Outline color
                        ),
                        elevation: 0,
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/icons/google_icon.jpg', // Replace with your asset path
                              width: 22.0, // Adjust the width as needed
                              height: 22.0, // Adjust the height as needed
                            ),
                            SizedBox(width: 20,),
                            Text(
                              'Continue With Google',
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 12,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 70,),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  },
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "Don't have an account? ",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.normal,
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        TextSpan(
                          text: 'Sign In',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.normal,
                            color: const Color(0xFF0AD3FF),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
