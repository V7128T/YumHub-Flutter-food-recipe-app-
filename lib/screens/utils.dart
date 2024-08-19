import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:food_recipe_app/screens/authentication_screen/email_signup_page.dart';
import 'package:food_recipe_app/main.dart';

void showGuestOverlay(BuildContext context) {
  showMaterialModalBottomSheet(
    context: context,
    builder: (context) => SingleChildScrollView(
      controller: ModalScrollController.of(context),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.info,
              color: Colors.orange,
              size: 48,
            ),
            const SizedBox(height: 20),
            const Text(
              'You are currently logged in as a guest.',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              'To access all features and personalize your experience, please create an account.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Future.delayed(
                  const Duration(seconds: 2),
                  () {
                    navKey.currentState?.pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (context) => const EmailSignUp()),
                      (route) => false,
                    );
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: Text(
                'Create an Account',
                style: GoogleFonts.roboto(
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
