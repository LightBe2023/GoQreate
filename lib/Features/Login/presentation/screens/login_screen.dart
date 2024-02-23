import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_qreate_teams/Features/Home/presentation/screens/home_screen.dart';
import 'package:go_qreate_teams/Features/Signup/presentation/screens/signup_screen.dart';
import 'package:go_qreate_teams/singleton/user_manager.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool obscureText = true;
  late TextEditingController _userNameController;
  late TextEditingController _passwordController;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> signInWithGoogle() async {
    try {
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

      // Get the first name from the Google account
      String? firstName = googleUser.displayName?.split(' ').first;

      // Save username and email to Firestore
      await saveUserToFirestore(userCredential.user?.email, firstName);
    } catch (e) {
      print('Failed to sign in with Google: $e');
    }
  }

  Future<void> saveUserToFirestore(String? email, String? firstName) async {
    if (email != null && firstName != null) {
      CollectionReference users =
      FirebaseFirestore.instance.collection('users');

      // Check if the user already exists in Firestore
      QuerySnapshot<Object?> snapshot =
      await users.where('email', isEqualTo: email).get();

      if (snapshot.docs.isEmpty) {
        // User does not exist in Firestore, add new user
        await users.add({
          'email': email,
          'userName': firstName, // Set first name as username for Google sign-in
          'password': '', // Set empty string as password
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _userNameController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    try {
      if (_formKey.currentState!.validate()) {
        // Assume you have a Firestore collection named 'users'
        CollectionReference users =
        FirebaseFirestore.instance.collection('users');

        // Check if the entered username exists in the 'users' collection
        QuerySnapshot<Object?> snapshot = await users
            .where('userName', isEqualTo: _userNameController.text)
            .get();

        if (snapshot.docs.isNotEmpty) {
          // User with the provided username exists
          // Now, you can perform authentication using the retrieved user data
          // For simplicity, let's assume the password is stored in the 'password' field
          var userData = snapshot.docs.first.data();
          var storedPassword = (userData as Map<String, dynamic>)['password'];
          var storedEmail = (userData)['email'];

          if (storedPassword == _passwordController.text) {
            // Passwords match, user is authenticated
            // Save the login state to shared preferences
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setBool('isLoggedIn', true);

            // Save the username to shared preferences if needed
            await prefs.setString('userName', _userNameController.text);
            await prefs.setString('userEmail', storedEmail);

            // Navigate to the home screen
            _goToHomeScreen();
          } else {
            // Passwords don't match
            // You may want to display an error message or handle this case accordingly
            print('Invalid password');
          }
        } else {
          // User with the provided username doesn't exist
          // You may want to display an error message or handle this case accordingly
          print('User not found');
        }
      }
    } catch (e) {
      print('Failed to sign in: $e');
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
          padding: const EdgeInsets.only(
              top: 100, bottom: 20, left: 20, right: 20),
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
                    'Welcome Back!',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 30,),
                TextFormField(
                  controller: _userNameController,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(16.0),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(color: Colors.black12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(color: Colors.black12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(color: Colors.black12),
                    ),
                    prefixIcon: Image.asset(
                      'assets/icons/person_icon.jpg',
                      width: 20.0,
                      height: 20.0,
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
                  obscureText: obscureText,
                  controller: _passwordController,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(16.0),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(color: Colors.black12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(color: Colors.black12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(color: Colors.black12),
                    ),
                    prefixIcon: Image.asset(
                      'assets/icons/key_icon.jpg',
                      width: 20.0,
                      height: 20.0,
                    ),
                    suffixIcon: GestureDetector(
                      onTap: () {
                        setState(() {
                          obscureText = !obscureText;
                        });
                      },
                      child: Image.asset(
                        obscureText
                            ? 'assets/icons/eye-slash.jpg'
                            : 'assets/icons/eye-slash.jpg',
                        width: 20.0,
                        height: 20.0,
                      ),
                    ),
                    hintText: 'Password',
                    hintStyle: TextStyle(
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
                const SizedBox(height: 30,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _signIn();
                        }

                        // Navigator.pushReplacement(
                        //   context,
                        //   MaterialPageRoute(builder: (context) => const HomeScreen()),
                        // );
                      },
                      style: ElevatedButton.styleFrom(
                        primary: const Color(0xFF0AD3FF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Text(
                          'Sign In',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
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
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const HomeScreen()));
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          side: BorderSide(
                              color: Colors.black.withOpacity(0.1)),
                        ),
                        elevation: 0,
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/icons/google_icon.jpg',
                              width: 22.0,
                              height: 22.0,
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
                      MaterialPageRoute(builder: (context) => const SignUpScreen()),
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
                          text: 'Sign Up',
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
