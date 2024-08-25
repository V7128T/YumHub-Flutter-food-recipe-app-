// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food_recipe_app/auth_methods/firebaseFunctions.dart';
import 'signin.dart';
import 'package:food_recipe_app/custom_colors/app_colors.dart';
import 'package:food_recipe_app/auth_methods/auth.dart';
import 'package:food_recipe_app/custom_dialogs/email_verification_dialog.dart';
import 'package:ionicons/ionicons.dart';
import 'package:page_transition/page_transition.dart';
import 'package:google_fonts/google_fonts.dart';

class EmailSignUp extends StatefulWidget {
  const EmailSignUp({super.key});

  @override
  State<EmailSignUp> createState() => _EmailSignUpState();
}

class _EmailSignUpState extends State<EmailSignUp> {
  String name = "", password = "", email = "";
  String uid = "";
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  final _formkey = GlobalKey<FormState>();
  bool isEmailVerified = false;
  var timer;

  @override
  void dispose() {
    timer?.cancel();

    super.dispose();
  }

  Future sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await user.sendEmailVerification();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Link has been sent.")),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'too-many-requests') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Too many request, please try again later."),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
          ),
        );
      }
    }
  }

  Future checkEmailVerified() async {
    // Call after email verification
    await FirebaseAuth.instance.currentUser!.reload();

    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });

    if (isEmailVerified) {
      timer?.cancel();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Email has been verified!"),
        ),
      );
      Navigator.push(
          context,
          PageTransition(
              type: PageTransitionType.fade, child: const LoginPage()));
    }
  }

  String? emailValidation(String? email) {
    RegExp emailRegex = RegExp(r'^[\w\.-]+@[\w-]+\.\w{2,3}(\.\w{2,3})?$');
    final isEmailValid = emailRegex.hasMatch(email ?? '');
    if (!isEmailValid) {
      return 'Please enter a valid email.';
    }
    return null;
  }

  void registration() async {
    if (passwordController.text != "" &&
        nameController.text != "" &&
        emailController.text != "") {
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
                email: emailController.text.trim(),
                password: passwordController.text.trim());
        uid = userCredential.user!.uid;
        await FirebaseAuth.instance.currentUser!
            .updateDisplayName(nameController.text.trim());
        await FirestoreServices.saveUser(
            emailController.text.trim(), uid, nameController.text.trim(), []);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Account created successfully.",
              style: TextStyle(fontSize: 15.0),
            ),
          ),
        );

        showEmailVerificationDialog(context);

        // User needs to be created before!
        isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;

        if (!isEmailVerified) {
          sendVerificationEmail();

          timer = Timer.periodic(
            const Duration(seconds: 3),
            (_) => checkEmailVerified(),
          );
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.orangeAccent,
              content: Text(
                "Password strength is too weak, please set a stronger password.",
                style: TextStyle(fontSize: 18.0),
              ),
            ),
          );
        } else if (e.code == 'email-already-in-use') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.orangeAccent,
              content: Text(
                "The email has already registered.",
                style: TextStyle(fontSize: 18.0),
              ),
            ),
          );
        }
      }
    }
  }

  void showEmailVerificationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EmailVerificationDialog(
          onResendLinkPressed: () async {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Resending email verification...")),
            );
            await Future.delayed(const Duration(seconds: 2));
            sendVerificationEmail();
          },
          description: "We have sent an email verification link to your email.",
          onDismiss: () async {
            timer?.cancel();
            // Delete user account and signout if the user cancelled the email verification
            await FirebaseAuth.instance.currentUser!.delete();
            await FirebaseAuth.instance.signOut();
            await FirestoreServices.deleteUser(uid);
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.orange[100]!, Colors.orange[50]!],
          ),
        ),
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: Colors.transparent,
          body: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(
                  height: 60.0,
                ),
                Text(
                  "Sign Up",
                  style: GoogleFonts.chivo(
                    textStyle: TextStyle(
                      fontSize: 30.0,
                      color: Colors.brown[800],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 325,
                  child: Image.asset(
                    "assets/man-cooking-enh.png",
                    fit: BoxFit.fitHeight,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 25.0, right: 25.0),
                  child: Form(
                    key: _formkey,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 1.5,
                            horizontal: 15.0,
                          ),
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
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: const Color(0xFFedf0f8),
                              width: 2.0,
                            ),
                          ),
                          child: TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please fill in your username.';
                              }
                              return null;
                            },
                            controller: nameController,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "Username",
                              hintStyle: const TextStyle(
                                  color: Color(0xFFb2b7bf), fontSize: 14.0),
                              prefixIcon: Icon(
                                Ionicons.person,
                                color: Colors.brown[400],
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
                            // Input Validation (EMAIL)
                            validator: emailValidation,
                            controller: emailController,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "Email",
                              hintStyle: const TextStyle(
                                  color: Color(0xFFb2b7bf), fontSize: 14.0),
                              prefixIcon: Icon(
                                Ionicons.mail,
                                color: Colors.brown[400],
                                size: 23.0,
                              ),
                              errorStyle: const TextStyle(
                                height: 1,
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
                                return 'Please fill in your password.';
                              }
                              return null;
                            },
                            controller: passwordController,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "Password",
                              hintStyle: const TextStyle(
                                  color: Color(0xFFb2b7bf), fontSize: 14.0),
                              prefixIcon: Icon(
                                Ionicons.lock_closed,
                                color: Colors.brown[400],
                                size: 25.0,
                              ),
                            ),
                            obscureText: true,
                          ),
                        ),
                        const SizedBox(
                          height: 20.0,
                        ),
                        GestureDetector(
                          onTap: () {
                            if (_formkey.currentState!.validate()) {
                              setState(() {
                                email = emailController.text;
                                name = nameController.text;
                                password = passwordController.text;
                              });
                            }
                            registration();
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            padding: const EdgeInsets.symmetric(
                                vertical: 13.0, horizontal: 30.0),
                            decoration: BoxDecoration(
                              color: Colors.brown[500],
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 3.0,
                                  spreadRadius: 1.0,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                "Register",
                                style: GoogleFonts.chivo(
                                  textStyle: const TextStyle(
                                    fontSize: 19.0,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 25.0,
                ),
                const Text(
                  "or",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 19.0,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(
                  height: 25.0,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 50.0, right: 50.0),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width,
                          padding: const EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 30.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: Colors.white70,
                              width: 2.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 5.0,
                                spreadRadius: 1.0,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: GestureDetector(
                            onTap: () {
                              // Sign in with google
                              AuthMethods().signInWithGoogle(context);
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  cacheHeight: 105,
                                  cacheWidth: 105,
                                  "assets/google-icon.jpeg",
                                  height: 32,
                                  width: 32,
                                  fit: BoxFit.cover,
                                ),
                                const SizedBox(
                                  width: 15.0,
                                ),
                                const Text(
                                  "Continue with Google",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 17.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 30.0,
                        ),
                      ],
                    ),
                  ),
                ),

                // Image.asset(
                //   cacheHeight: 105,
                //   cacheWidth: 105,
                //   "assets/facebook-icon.png",
                //   height: 35,
                //   width: 35,
                //   fit: BoxFit.cover,
                // )
                const SizedBox(
                  height: 25.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account?",
                        style: TextStyle(
                            color: Color(0xFF8c8e98),
                            fontSize: 15.0,
                            fontWeight: FontWeight.w500)),
                    const SizedBox(
                      width: 5.0,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            PageTransition(
                                type: PageTransitionType.fade,
                                child: const LoginPage()));
                      },
                      child: const Text(
                        "Login",
                        style: TextStyle(
                            color: AppColors.defaultRed,
                            fontSize: 15.0,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
