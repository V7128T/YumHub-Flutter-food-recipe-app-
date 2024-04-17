import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

typedef OnResendLinkPressed = void Function();

class EmailVerificationDialog extends StatefulWidget {
  const EmailVerificationDialog({
    super.key,
    required this.onResendLinkPressed,
    required this.onDismiss,
    this.isLoading = false,
    this.description = "We have sent a email verification link to your email.",
  });

  final bool isLoading;
  final String description;
  final OnResendLinkPressed onResendLinkPressed;
  final VoidCallback onDismiss;

  @override
  _EmailVerificationDialogState createState() =>
      _EmailVerificationDialogState();
}

class _EmailVerificationDialogState extends State<EmailVerificationDialog> {
  bool _isResendButtonDisabled = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      backgroundColor: Colors.white,
      elevation: 12,
      child: Stack(
        children: <Widget>[
          Container(
            height: 390,
            padding: const EdgeInsets.only(left: 25.0, right: 25.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (widget.isLoading)
                  const CircularProgressIndicator.adaptive(),
                if (!widget.isLoading)
                  Image.asset(
                    "assets/verify_email.gif",
                    fit: BoxFit.fitWidth,
                    height: 200,
                  ),
                const SizedBox(height: 5.0),
                Text(
                  "Please check your email",
                  style: GoogleFonts.chivo(
                    textStyle: const TextStyle(
                      fontSize: 20.0,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8.0),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    widget.description,
                    style: GoogleFonts.chivo(
                      textStyle: const TextStyle(
                        fontSize: 14.0,
                        color: Colors.black,
                      ),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24.0),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      backgroundColor: Colors.blue,
                    ),
                    onPressed: _isResendButtonDisabled
                        ? null
                        : () {
                            setState(() {
                              _isResendButtonDisabled = true;
                            });
                            widget.onResendLinkPressed();
                            // Re-enable the button after 10 secs
                            Future.delayed(const Duration(seconds: 30), () {
                              if (mounted) {
                                setState(() {
                                  _isResendButtonDisabled = false;
                                });
                              }
                            });
                          },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16.0,
                        horizontal: 24.0,
                      ),
                      child: Text(
                        "Resend Link",
                        style: GoogleFonts.chivo(
                          textStyle: const TextStyle(
                            fontSize: 15.0,
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
          Positioned(
            right: 8.0,
            top: 8.0,
            child: IconButton(
              onPressed: () {
                widget.onDismiss();
                Navigator.of(context).pop();
              },
              icon: const Icon(
                Icons.close,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
