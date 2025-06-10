import 'dart:developer';

import 'package:complaintsapp/AppClient/Models/LoginDtos/login_req.dart';
import 'package:complaintsapp/AppClient/Services/_shared_prefs_helper.dart';
import 'package:complaintsapp/Ui/Authentication_Screens/Login/bloc/login_bloc.dart';
import 'package:complaintsapp/Ui/Authentication_Screens/widgets/authTextField.dart';
import 'package:complaintsapp/Ui/shared/collapse_menu.dart';
import 'package:complaintsapp/Ui/shared/constants/colors&fonts.dart';
import 'package:complaintsapp/Ui/shared/dialog_manager.dart';
import 'package:complaintsapp/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isInit = false;
  String locale = SharedPrefs().language == 'ar' ? 'ar' : 'en';
  @override
  void initState() {
    super.initState();

    _emailController.text = "";
    _passwordController.text = "";
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
      _emailController.text = extras != null && extras['email'] != null ? extras['email'] : "";
      _passwordController.text = extras != null && extras['password'] != null ? extras['password'] : "";

      _isInit = true; // Set flag to true so this block doesn't run again
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
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
          child: BlocProvider(
            create: (context) => LoginBloc(),
            child: Stack(
              children: [
                BlocConsumer<LoginBloc, LoginState>(
                  listener: (context, state) {
                    if (state is LoginSuccess) {
                      DialogManager.customDialog(
                        isDismissible: false,
                        context,
                        AppLocalizations.of(context)!.loginSuccess,
                        dialogType: DialogType.success,
                        buttonTitle: AppLocalizations.of(context)!.ok,
                        onPressed: () {
                          GoRouter.of(context).go('/home');
                        },
                      );
                    } else if (state is LoginLoading) {
                      DialogManager.customDialog(
                        context,
                        AppLocalizations.of(context)!.pleaseWait,
                        dialogType: DialogType.waiting,
                        isDismissible: false,
                      );
                    } else if (state is LoginFailure) {
                      DialogManager.customDialog(
                        context,
                        AppLocalizations.of(context)!.loginError,
                        dialogType: DialogType.error,
                        buttonTitle: AppLocalizations.of(context)!.ok,
                        onPressed: () {},
                        childWidget: CollapsibleErrorWidget(
                          errorText: state.loginResponse?.message ?? state.error.toString(),
                          dialogType: DialogType.error,
                        ),
                      );
                    }
                  },
                  builder: (context, state) {
                    return Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/app_icon.png',
                                  height: 120,
                                  width: 120,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(height: 25),
                            Center(
                              child: Text(
                                textAlign: TextAlign.center,
                                AppLocalizations.of(context)!.hello,
                                style: GoogleFonts.cairo(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white, // Gold
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              AppLocalizations.of(context)!.loginYourAccount,
                              style: GoogleFonts.cairo(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 30),
                            Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  AuthTextField(
                                    controller: _emailController,
                                    label: AppLocalizations.of(context)!.email,
                                    icon: Icons.email_outlined,
                                    validator: (value) => value!.isEmpty || !value.contains('@') ? 'Enter valid email' : null,
                                  ),
                                  const SizedBox(height: 20),
                                  AuthTextField(
                                    controller: _passwordController,
                                    label: AppLocalizations.of(context)!.password,
                                    icon: Icons.lock_outline,
                                    obscureText: _obscurePassword,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                        color: Colors.white,
                                      ),
                                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                    ),
                                    validator: (value) => value!.length < 6 ? 'Password must be at least 6 characters' : null,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 30),
                            ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  context.read<LoginBloc>().add(
                                        LoginUserEvent(
                                            loginRequest: LoginRequest(
                                          email: _emailController.text.trim(),
                                          password: _passwordController.text.trim(),
                                        )),
                                      );
                                  // Handle login logic
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white, // Gold
                                minimumSize: const Size.fromHeight(50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 5,
                              ),
                              child: Text(
                                AppLocalizations.of(context)!.loginButton,
                                style: GoogleFonts.cairo(
                                  fontSize: 16,
                                  color: const Color(0xFF1E3C72), // Deep navy text
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextButton(
                              onPressed: () {},
                              child: Text(
                                AppLocalizations.of(context)!.forgotPassword,
                                style: GoogleFonts.cairo(
                                  fontSize: 14,
                                  color: Colors.white70, // Light gray
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextButton(
                              onPressed: () {
                                GoRouter.of(context).go('/register');
                              },
                              child: RichText(
                                text: TextSpan(
                                  style: GoogleFonts.cairo(fontSize: 14),
                                  children: [
                                    TextSpan(
                                      text: AppLocalizations.of(context)!.dontHaveAccount + ' ',
                                      style: GoogleFonts.cairo(
                                        color: Colors.white70,
                                      ),
                                    ),
                                    TextSpan(
                                      text: AppLocalizations.of(context)!.signUp,
                                      style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
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
                        locale,
                        style: const TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        setState(() {
                          locale = SharedPrefs().language == "ar" ? "AR" : "EN";
                        });
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
      ),
    );
  }
}
