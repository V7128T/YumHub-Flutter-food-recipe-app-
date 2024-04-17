// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food_recipe_app/screens/nav/bottom_nav_screen.dart';
import 'package:food_recipe_app/custom_colors/app_colors.dart';
import 'email_signup_page.dart';
import 'resetpassword.dart';
import 'package:food_recipe_app/auth_methods/auth.dart';
import 'package:ionicons/ionicons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String email = "", password = "";
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final _formkey = GlobalKey<FormState>();

  Future<void> userLogin() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text, password: passwordController.text);

      Navigator.push(
          context,
          PageTransition(
              type: PageTransitionType.fade, child: BottomNavView()));
    } on FirebaseAuthException catch (e) {
      print(e);
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Colors.orangeAccent,
            content: Text(
              "No user found for that email.",
              style: TextStyle(fontSize: 15.0),
            )));
      } else if (e.code == 'invalid-credential') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Colors.orangeAccent,
            content: Text(
              "Invalid credentials.",
              style: TextStyle(fontSize: 15.0),
            )));
      } else if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Incorrect password.",
              style: TextStyle(fontSize: 15.0),
            ),
          ),
        );
      } else if (e.code == 'invalid-email') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
            "Invalid email format.",
            style: TextStyle(fontSize: 15.0),
          )),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.defaultBackground,
      body: SingleChildScrollView(
          child: Column(
        children: [
          const SizedBox(
            height: 60.0,
          ),
          const SizedBox(
            height: 5.0,
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Image.asset(
              "assets/woman-cooking-enh.png",
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(
            height: 20.0,
          ),
          Text(
            "Login",
            style: GoogleFonts.chivo(
              textStyle: const TextStyle(
                fontSize: 29.0,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            "Up to 5000+ Recipes awaiting.",
            style: GoogleFonts.chivo(
              textStyle: const TextStyle(
                fontSize: 15.0,
                color: Colors.black,
              ),
            ),
          ),
          Text(
            "Login to get access to more features!",
            style: GoogleFonts.chivo(
              textStyle: const TextStyle(
                fontSize: 15.0,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(
            height: 40.0,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20.0),
            child: Form(
              key: _formkey,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 1.5, horizontal: 15.0),
                    decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 9.0,
                            spreadRadius: 1.0,
                            offset: const Offset(0, 3),
                          ),
                        ],
                        color: const Color(0xFFedf0f8),
                        borderRadius: BorderRadius.circular(30)),
                    child: TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please fill in your Email.';
                        }
                        return null;
                      },
                      controller: emailController,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Email",
                        hintStyle: TextStyle(
                          fontSize: 14.0,
                          color: Color(0xFFb2b7bf),
                        ),
                        prefixIcon: Icon(
                          Ionicons.mail,
                          color: AppColors.defaultRed,
                          size: 23.0,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 1.5, horizontal: 15.0),
                    decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 9.0,
                            spreadRadius: 1.0,
                            offset: const Offset(0, 3),
                          ),
                        ],
                        color: const Color(0xFFedf0f8),
                        borderRadius: BorderRadius.circular(30)),
                    child: TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please fill in your Password.';
                        }
                        return null;
                      },
                      controller: passwordController,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Password",
                        hintStyle: TextStyle(
                          fontSize: 14.0,
                          color: Color(0xFFb2b7bf),
                        ),
                        prefixIcon: Icon(
                          Ionicons.lock_closed,
                          color: AppColors.defaultRed,
                          size: 25.0,
                        ),
                      ),
                      obscureText: true,
                    ),
                  ),
                  const SizedBox(
                    height: 5.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              PageTransition(
                                  type: PageTransitionType.fade,
                                  child: const ForgotPassword()));
                        },
                        child: const Text("Forgot Password?",
                            style: TextStyle(
                                color: AppColors.defaultRed,
                                fontSize: 13.0,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  GestureDetector(
                    // Signin button
                    onTap: () {
                      if (_formkey.currentState!.validate()) {
                        setState(() {
                          email = emailController.text;
                          password = passwordController.text;
                        });
                      }
                      userLogin();
                    },
                    child: Container(
                        width: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.symmetric(
                            vertical: 13.0, horizontal: 30.0),
                        decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 3.0,
                                spreadRadius: 1.0,
                                offset: const Offset(0, 3),
                              ),
                            ],
                            color: AppColors.defaultRed,
                            borderRadius: BorderRadius.circular(30)),
                        child: Center(
                            child: Text(
                          "Login",
                          style: GoogleFonts.chivo(
                            textStyle: const TextStyle(
                              fontSize: 19.0,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ))),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 25.0,
          ),
          Text(
            "or",
            style: GoogleFonts.chivo(
              textStyle: const TextStyle(
                fontSize: 19.0,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(
            height: 25.0,
          ),
          Text(
            "Login using",
            style: GoogleFonts.chivo(
              textStyle: const TextStyle(
                fontSize: 15.0,
                color: Colors.black,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
          const SizedBox(
            height: 10.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                // Sign in with Google
                onTap: () {
                  AuthMethods().signInWithGoogle(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 2.0,
                        spreadRadius: 1.0,
                        offset: const Offset(-2, 4),
                      ),
                    ],
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Image.asset(
                    cacheHeight: 105,
                    cacheWidth: 105,
                    "assets/google-icon.jpeg",
                    height: 40,
                    width: 40,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(
                width: 30.0,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      PageTransition(
                          type: PageTransitionType.fade,
                          child: const EmailSignUp()));
                },
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 2.0,
                        spreadRadius: 1.0,
                        offset: const Offset(-2, 4),
                      ),
                    ],
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Image.asset(
                    cacheHeight: 105,
                    cacheWidth: 105,
                    "assets/email-icon.png",
                    height: 40,
                    width: 40,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 25.0,
          ),
        ],
      )),
    );
  }
}
