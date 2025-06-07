import 'dart:developer';

import 'package:app_links/app_links.dart';
import 'package:complaintsapp/AppClient/Services/_shared_prefs_helper.dart';
import 'package:complaintsapp/Ui/shared/constants/colors&fonts.dart';
import 'package:complaintsapp/Ui/shared/dialog_manager.dart';
import 'package:complaintsapp/main.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ConfirmEmailScreen extends StatefulWidget {
  const ConfirmEmailScreen({super.key, String? email, String? token});

  @override
  State<ConfirmEmailScreen> createState() => _ConfirmEmailscreenState();
}

class _ConfirmEmailscreenState extends State<ConfirmEmailScreen> {
  void initState() {
    super.initState();
    _handleIncomingLinks();
  }

  void _handleIncomingLinks() async {
    final appLinks = AppLinks();

    // Handle initial link if app was opened via deep link
    final Uri? initialLinkString = await appLinks.getInitialLink();
    if (initialLinkString != null) {
      final Uri initialUri = initialLinkString;
      initDeepLink(initialUri);
    }

    // Listen to link changes (if app already opened)
    appLinks.uriLinkStream.listen((Uri uri) {
      initDeepLink(uri);
    });
  }

  Future<void> initDeepLink(Uri uri) async {
    try {
      print("Received deep link: $uri");

      if (uri.scheme == 'complaintsapp' && uri.host == 'confirm-email') {
        final email = uri.queryParameters['email'];
        final jwt = uri.queryParameters['jwt']; // <-- Get actual login token

        if (email != null && jwt != null) {
          print("Email confirmed. Logging in user: $email");
          SharedPrefs().userEmail = email;
          SharedPrefs().token = jwt;

          // Optional: Verify token validity with backend before redirecting

          GoRouter.of(context).go('/home');
        } else {
          // JWT is missing — show success message but ask to log in manually
          DialogManager.customDialog(
            context,
            'Email Verified',
            dialogType: DialogType.success,
            buttonTitle: 'Login',
            onPressed: () => GoRouter.of(context).go('/login'),
            childWidget: Text(
              'Your email ($email) was successfully verified.\nPlease log in to continue.',
              textAlign: TextAlign.center,
            ),
          );
        }
      }
    } catch (e) {
      print("Error handling deep link: $e");
    }
  }

  String? email;
  String? token;
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1E3C72), // Your primary color
                Color(0xFF2A5298), // A matching rich blue
                Color(0xFF4A90E2), // Softer blue highlight
              ],
            ),
          ),
          child: Stack(
            children: [
              Center(
                child: Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  color: Colors.white.withOpacity(0.9),
                  child: Padding(
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.email_outlined,
                          size: 80,
                          color: AppColors.primaryColor,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          textAlign: TextAlign.center,
                          AppLocalizations.of(context)!.emailVerification,
                          style: GoogleFonts.cairo(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          AppLocalizations.of(context)!.weSentEmail,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          email ?? '',
                          style: GoogleFonts.cairo(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          AppLocalizations.of(context)!.pleaseCheck,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Or navigate elsewhere
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 5,
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.backToLogin,
                            style: GoogleFonts.cairo(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: Colors.white70),
                      ),
                    ),
                    icon: const Icon(Icons.language, color: Colors.white),
                    label: Text(
                      SharedPrefs().language == "en" ? "EN" : "AR",
                      style: const TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      if (SharedPrefs().language == "en") {
                        SharedPrefs().language = "ar";
                      } else {
                        SharedPrefs().language = "en";
                      }
                      log(SharedPrefs().language);
                      MyApp.setLocale(context, Locale(SharedPrefs().language));
                    },
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
