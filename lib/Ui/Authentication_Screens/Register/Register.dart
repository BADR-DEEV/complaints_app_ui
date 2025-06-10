import 'dart:developer';
import 'package:complaintsapp/AppClient/Models/RegisterDtos/register_req.dart';
import 'package:complaintsapp/AppClient/Services/_shared_prefs_helper.dart';
import 'package:complaintsapp/Ui/Authentication_Screens/Register/bloc/bloc/register_bloc.dart';
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

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RegisterBloc(),
      child: SafeArea(
        child: Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF1E3C72), // Your primary color
                  Color(0xFF2A5298), // A matching rich blue
                  Color(0xFF4A90E2), // Softer blue highlight
                ],
              ),
            ),
            child: Stack(
              children: [
                BlocConsumer<RegisterBloc, RegisterState>(
                  listener: (context, state) {
                    if (state is RegisterSuccess) {
                      DialogManager.customDialog(
                        context,
                        AppLocalizations.of(context)!.registerSuccess,
                        dialogType: DialogType.success,
                        buttonTitle: AppLocalizations.of(context)!.ok,
                        onPressed: () {
                          SharedPrefs().emailToken = state.registerResponse.message;
                          GoRouter.of(context).go(
                            '/confirm-email',
                            extra: {
                              'email': _emailController.text,
                              'password': _passwordController.text, // Provide password if available
                            },
                          );
                        },
                      );
                    } else if (state is RegisterLoading) {
                      DialogManager.customDialog(
                        context,
                        AppLocalizations.of(context)!.pleaseWait,
                        dialogType: DialogType.waiting,
                        isDismissible: false,
                      );
                    } else if (state is RegisterFailure) {
                      DialogManager.customDialog(
                        context,
                        AppLocalizations.of(context)!.registerError,
                        dialogType: DialogType.error,
                        buttonTitle: AppLocalizations.of(context)!.ok,
                        onPressed: () {},
                        childWidget: CollapsibleErrorWidget(
                          errorText: state.registerResponse?.message ?? state.error.toString(),
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
                                    color: Colors.black.withOpacity(0.15),
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
                            Text(
                              AppLocalizations.of(context)!.registerHeader,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.cairo(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              AppLocalizations.of(context)!.registerYourAccount,
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
                                    isEnd: false,
                                    controller: _nameController,
                                    label: AppLocalizations.of(context)!.name,
                                    icon: Icons.person_outline,
                                    validator: (value) => value!.isEmpty ? 'Enter your name' : null,
                                  ),
                                  const SizedBox(height: 20),
                                  AuthTextField(
                                    isEnd: false,
                                    controller: _emailController,
                                    label: AppLocalizations.of(context)!.email,
                                    icon: Icons.email_outlined,
                                    validator: (value) => value!.isEmpty || !value.contains('@') ? 'Enter valid email' : null,
                                  ),
                                  const SizedBox(height: 20),
                                  AuthTextField(
                                    isEnd: true,
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
                                  context.read<RegisterBloc>().add(
                                        RegisterUserEvent(
                                          registerRequest: RegisterRequest(
                                            displayName: _nameController.text.trim(),
                                            email: _emailController.text.trim(),
                                            password: _passwordController.text.trim(),
                                          ),
                                        ),
                                      );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                minimumSize: const Size.fromHeight(50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 5,
                              ),
                              child: Text(
                                AppLocalizations.of(context)!.registerButton,
                                style: GoogleFonts.cairo(
                                  fontSize: 16,
                                  color: Color(0xFF1E3C72), // Deep Blue Text
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextButton(
                              onPressed: () {
                                GoRouter.of(context).go('/');
                              },
                              child: RichText(
                                text: TextSpan(
                                  style: GoogleFonts.cairo(fontSize: 14),
                                  children: [
                                    TextSpan(
                                      text: AppLocalizations.of(context)!.alreadyHaveAccount + ' ',
                                      style: const TextStyle(color: Colors.white70),
                                    ),
                                    TextSpan(
                                      text: AppLocalizations.of(context)!.signIn,
                                      style: const TextStyle(color: Colors.white),
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
      ),
    );
  }
}
