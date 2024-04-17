import 'package:food_recipe_app/custom_colors/app_colors.dart';

import 'email_signup_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  String email = "";
  TextEditingController emailcontroller = TextEditingController();

  final _formkey = GlobalKey<FormState>();

  resetPassword() async {
    try {
      // If the email is registered, send password recovery link
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
        "Password reset link has been sent to your email, please check your email!",
        style: TextStyle(fontSize: 15.0),
      )));
    } on FirebaseAuthException catch (e) {
      print(e);
      // If the email is not registered, show an error message
      if (e.code == "invalid-credential") {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
          "User is not registered.",
          style: TextStyle(fontSize: 20.0),
        )));
      } else {
        print("Error: ${e.code}");
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
          "An error occurred while sending the password reset email. Please try again.",
          style: TextStyle(fontSize: 15.0),
        )));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.defaultWhite,
      body: Container(
        child: Column(
          children: [
            const SizedBox(
              height: 300.0,
            ),
            Container(
              alignment: Alignment.topCenter,
              child: const Text(
                "Password Recovery",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 30.0,
                    fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(
              height: 10.0,
            ),
            const Text(
              "Enter your email to recover your password.",
              style: TextStyle(color: Colors.black, fontSize: 16.0),
            ),
            Expanded(
                child: Form(
                    key: _formkey,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                      child: ListView(
                        children: [
                          Container(
                            padding: const EdgeInsets.only(left: 10.0),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: AppColors.defaultRed, width: 2.0),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: TextFormField(
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email.';
                                }
                                return null;
                              },
                              controller: emailcontroller,
                              style: const TextStyle(color: Colors.black),
                              decoration: const InputDecoration(
                                  hintText: "Email",
                                  hintStyle: TextStyle(
                                      fontSize: 18.0,
                                      color: AppColors.defaultRed),
                                  prefixIcon: Icon(
                                    Icons.person,
                                    color: AppColors.defaultRed,
                                    size: 30.0,
                                  ),
                                  border: InputBorder.none),
                            ),
                          ),
                          const SizedBox(
                            height: 25.0,
                          ),
                          GestureDetector(
                            onTap: () {
                              if (_formkey.currentState!.validate()) {
                                setState(() {
                                  email = emailcontroller.text;
                                });
                                resetPassword();
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  color: AppColors.defaultRed,
                                  borderRadius: BorderRadius.circular(10)),
                              child: const Center(
                                child: Text(
                                  "Send Link",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10.0,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Don't have an account?",
                                style: TextStyle(
                                    fontSize: 15.0, color: Colors.black),
                              ),
                              const SizedBox(
                                width: 5.0,
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const EmailSignUp()));
                                },
                                child: const Text(
                                  "Create",
                                  style: TextStyle(
                                      color: Colors.blue,
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.bold),
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ))),
          ],
        ),
      ),
    );
  }
}
