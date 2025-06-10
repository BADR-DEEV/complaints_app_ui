import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:app_links/app_links.dart';
import 'package:complaintsapp/AppClient/Models/User/UserResponseDto.dart';
import 'package:complaintsapp/AppClient/Services/_shared_prefs_helper.dart';
import 'package:complaintsapp/Ui/shared/constants/colors&fonts.dart';
import 'package:complaintsapp/Ui/shared/dialog_manager.dart';
import 'package:complaintsapp/main.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ConfirmEmailScreen extends StatefulWidget {
  final String? password;
  final String? passed_email;
  ConfirmEmailScreen({super.key, String? token, this.password, this.passed_email});

  @override
  State<ConfirmEmailScreen> createState() => _ConfirmEmailscreenState();
}

class _ConfirmEmailscreenState extends State<ConfirmEmailScreen> with WidgetsBindingObserver {
  StreamSubscription<Uri>? _uriLinkSubscription;
  Uri? _lastProcessedUri; // To prevent processing the same URI multiple times
  bool _isInit = false;
  String real_passed_email = '';

  @override
  void initState() {
    super.initState();
    _lastProcessedUri = Uri();

    WidgetsBinding.instance.addObserver(this);
    _handleIncomingLinks();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Crucially, cancel the subscription when the widget is disposed
    _lastProcessedUri = null;
    _uriLinkSubscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Only run this logic once after the first build or whenever dependencies change
    // This is the correct place to access InheritedWidgets like GoRouterState.of(context)
    if (!_isInit) {
      final extraData = GoRouterState.of(context).extra;
      Map<String, dynamic>? extras;

      if (extraData != null && extraData is Map<String, dynamic>) {
        extras = extraData;
      }

      // Safely assign text to controllers based on extra data
      real_passed_email = extras != null && extras['email'] != null ? extras['email'] : "";

      _isInit = true; // Set flag to true so this block doesn't run again
    }
  }

  void _handleIncomingLinks() async {
    final appLinks = AppLinks();

    // Handle initial link if app was opened via deep link
    try {
      final Uri? initialLinkString = await appLinks.getInitialLink();

      if (initialLinkString != null) {
        print(initialLinkString);
        print(_lastProcessedUri);

        // Process initial link only if it hasn't been processed
        if (_lastProcessedUri != initialLinkString) {
          _lastProcessedUri = initialLinkString;
          initDeepLink(initialLinkString);
        }
      }
    } catch (e) {
      print("Error getting initial link: $e");
    }

    // Listen to link changes (if app already opened)
    _uriLinkSubscription = appLinks.uriLinkStream.listen((Uri uri) {
      // Process only if it's a new URI or different from the last one processed
      if (_lastProcessedUri != uri) {
        _lastProcessedUri = uri;
        initDeepLink(uri);
      }
    }, onError: (err) {
      print('Got error: $err');
    });
  }

  Future<void> initDeepLink(Uri uri) async {
    try {
      final uriString = uri.toString();

      // Prevent re-handling the same link
      if (SharedPrefs().lastUri == uriString) {
        print("This link has already been handled. Skipping.");
        return;
      }

      SharedPrefs().lastUri = uriString;
      print("Received deep link: $uri");

      if (uri.scheme == 'complaintsapp' && uri.host == 'confirm-email') {
        final email = uri.queryParameters['email'];
        final responseParam = uri.queryParameters['response'];
        final receivedToken = uri.queryParameters['token'];

        final savedEmail = real_passed_email?.trim().toLowerCase();
        final receivedEmail = email?.trim().toLowerCase();
        final savedUrl = SharedPrefs().emailToken;

        print("Response: $responseParam");
        print("Saved email: $savedEmail");
        print("Received email: $receivedEmail");
        print("Received token: $receivedToken");
        print("Saved token: $savedUrl");

        // Extract the token from the saved URL
        final savedUri = Uri.tryParse(savedUrl ?? '');
        final savedToken = savedUri?.queryParameters['token'];

        print("Extracted saved token: $savedToken");

        if (responseParam == "200" && receivedEmail == savedEmail && receivedToken == savedToken) {
          SharedPrefs().userEmail = email;

          print("Going to login screen...");
          DialogManager.customDialog(
            isDismissible: false,
            context,
            AppLocalizations.of(context)!.yourAccount,
            dialogType: DialogType.success,
            buttonTitle: AppLocalizations.of(context)!.ok,
            onPressed: () {
              GoRouter.of(context).go(
                '/',
                extra: {
                  'email': email,
                  'password': widget.password,
                },
              );
            },
          );
        } else {
          print("Email/token mismatch or invalid response.");
          // DialogManager.customDialog(
          //   context,
          //   'Email Not Verified',
          //   dialogType: DialogType.error,
          //   buttonTitle: 'Ok',
          //   onPressed: () {
          //     Navigator.of(context).pop();
          //   },
          //   childWidget: const Text(
          //     '',
          //     textAlign: TextAlign.center,
          //   ),
          // );
        }
      }
    } catch (e) {
      SharedPrefs().isLoggedIn = false; // Ensure this is only set if logic warrants it
      print("Error handling deep link: $e");
      // Consider showing an error dialog to the user here
      DialogManager.customDialog(
        context,
        "Something went wrong", // Generic error
        dialogType: DialogType.error,
        buttonTitle: AppLocalizations.of(context)!.ok,
        onPressed: () => Navigator.of(context).pop(),
      );
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
                          (AppLocalizations.of(context)!.weSentEmail + (real_passed_email != null ? real_passed_email.toString() : "")),
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
