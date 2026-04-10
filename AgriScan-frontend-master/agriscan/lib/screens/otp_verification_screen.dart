import 'package:flutter/material.dart';
import '../services/api.dart';
import 'home_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;

  const OtpVerificationScreen({
    super.key,
    required this.email,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  // Color Palette
  static const Color lightBackground = Color(0xFFE5E0D8);
  static const Color sageGreen = Color(0xFFACB087);
  static const Color darkGreen = Color(0xFF4C6444);
  static const Color accentBrown = Color(0xFF95714F);
  static const Color fieldBackground = Color(0xFFEADED0);

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBackground,
      appBar: AppBar(
        title: const Text(
          'Verify OTP',
          style: TextStyle(color: darkGreen),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: darkGreen),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),

              Text(
                'Enter the 6-digit code sent to ${widget.email}',
                style: const TextStyle(
                  fontSize: 16,
                  color: darkGreen,
                ),
              ),

              const SizedBox(height: 24),

              // OTP Input
              Form(
                key: _formKey,
                child: TextFormField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: darkGreen),
                  decoration: InputDecoration(
                    labelText: 'OTP',
                    labelStyle: TextStyle(color: darkGreen.withOpacity(0.7)),
                    filled: true,
                    fillColor: fieldBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: sageGreen),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: sageGreen),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: darkGreen, width: 2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: accentBrown),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: accentBrown, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Enter the OTP';
                    if (value.length < 4) return 'OTP too short';
                    return null;
                  },
                ),
              ),

              const SizedBox(height: 24),

              // VERIFY BUTTON
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        if (_formKey.currentState!.validate()) {
                          final otp = _otpController.text.trim();

                          setState(() => isLoading = true);

                          try {
                            await Api.verifyOtp(widget.email, otp);

                            setState(() => isLoading = false);

                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const HomeScreen(),
                              ),
                              (route) => false,
                            );
                          } catch (e) {
                            setState(() => isLoading = false);

                            final String msg =
                                e.toString().replaceAll("Exception: ", "");

                            // Session expired handling
                            if (msg.toLowerCase().contains('expired')) {
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  backgroundColor: lightBackground,
                                  title: const Text(
                                    'Session expired',
                                    style: TextStyle(color: darkGreen),
                                  ),
                                  content: const Text(
                                    'Your signup session expired. You can resend the OTP or go back to Sign Up.',
                                    style: TextStyle(color: darkGreen),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () async {
                                        Navigator.of(context).pop();

                                        setState(() => isLoading = true);

                                        try {
                                          await Api.resendOtp(widget.email);
                                          setState(() => isLoading = false);

                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: const Text('OTP resent'),
                                              backgroundColor: sageGreen,
                                            ),
                                          );
                                        } catch (e) {
                                          setState(() => isLoading = false);

                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                e.toString().replaceAll(
                                                    "Exception: ", ""),
                                              ),
                                              backgroundColor: accentBrown,
                                            ),
                                          );
                                        }
                                      },
                                      child: const Text(
                                        'Resend OTP',
                                        style: TextStyle(color: sageGreen),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text(
                                        'Back',
                                        style: TextStyle(color: accentBrown),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(msg),
                                  backgroundColor: accentBrown,
                                ),
                              );
                            }
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: darkGreen,
                  foregroundColor: lightBackground,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  disabledBackgroundColor: sageGreen.withOpacity(0.5),
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Verify',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),

              const SizedBox(height: 12),

              // RESEND OTP BUTTON
              TextButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        setState(() => isLoading = true);

                        try {
                          await Api.resendOtp(widget.email);
                          setState(() => isLoading = false);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('OTP resent'),
                              backgroundColor: sageGreen,
                            ),
                          );
                        } catch (e) {
                          setState(() => isLoading = false);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                e.toString().replaceAll("Exception: ", ""),
                              ),
                              backgroundColor: accentBrown,
                            ),
                          );
                        }
                      },
                style: TextButton.styleFrom(
                  foregroundColor: sageGreen,
                  disabledForegroundColor: sageGreen.withOpacity(0.5),
                ),
                child: const Text(
                  'Resend OTP',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}