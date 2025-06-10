import 'package:complaintsapp/AppClient/Services/_shared_prefs_helper.dart';
import 'package:complaintsapp/Ui/home/bloc/home_bloc.dart';
import 'package:complaintsapp/Ui/shared/dialog_manager.dart';
import 'package:complaintsapp/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

// Custom clipper for the curved bottom of the AppBar background
class BottomCurvedClipper extends CustomClipper<Path> {
  final double curveHeight; // Controls how deep the curve is

  BottomCurvedClipper({this.curveHeight = 20.0}); // Default curve height

  @override
  Path getClip(Size size) {
    final Path path = Path();

    // Start drawing from the top-left corner
    path.lineTo(0, size.height - curveHeight);

    // Define the control point and end point for the quadratic Bezier curve
    // The control point is at the very bottom center of the AppBar,
    // creating a smooth dip.
    final Offset controlPoint = Offset(size.width / 2, size.height);
    // The end point of the curve is at the bottom-right before going up
    final Offset endPoint = Offset(size.width, size.height - curveHeight);

    // Draw a quadratic Bezier curve that forms the dip in the middle
    // It starts from (0, size.height - curveHeight),
    // curves through `controlPoint` (mid-bottom),
    // and ends at `endPoint` (right bottom before ascending).
    path.quadraticBezierTo(
      controlPoint.dx,
      controlPoint.dy,
      endPoint.dx,
      endPoint.dy,
    );

    // Draw a line from the end of the curve to the top-right corner
    path.lineTo(size.width, 0);

    // Close the path to form a complete shape (back to top-left)
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    // Only reclip if the curveHeight changes to optimize performance
    if (oldClipper is BottomCurvedClipper) {
      return oldClipper.curveHeight != curveHeight;
    }
    return false;
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  // Define the height of the curve, this will also affect the total AppBar height
  final double _curveHeight = 20.0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        return Localizations.override(
          // Use const Locale("en") for better compile-time constant usage
          locale: const Locale("en"),
          context: context,
          child: AppBar(
            elevation: 4, // Keeps the shadow
            centerTitle: true,
            // Set AppBar's background to transparent so that only the flexibleSpace's gradient is visible
            backgroundColor: Colors.transparent,
            // No need for a specific shape here, as flexibleSpace with ClipPath handles the curve

            leading: Container(
              constraints: const BoxConstraints(maxWidth: 100), // Prevent overflow
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    iconSize: 30,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    icon: const Icon(Icons.language, color: Colors.white),
                    tooltip: 'Change Language',
                    onPressed: () async {
                      String currentLang = SharedPrefs().language;
                      String newLang = currentLang == 'ar' ? 'en' : 'ar';
                      Locale locale = Locale(newLang);
                      SharedPrefs().language = newLang;
                      // Use MyApp.setLocale to update the app's locale
                      MyApp.setLocale(context, locale);
                      // Navigate to home, which will rebuild the app with the new locale
                      GoRouter.of(context).go('/home');
                    },
                  ),
                  Flexible(
                    child: Text(
                      SharedPrefs().language.toUpperCase(),
                      style: GoogleFonts.cairo(fontSize: 12, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            title: Text(
              state is NavigationState && state.selectedIndex == 0 ? AppLocalizations.of(context)!.myComplaints : AppLocalizations.of(context)!.subComp,
              style: GoogleFonts.cairo(
                fontSize: 22,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            actions: [
              IconButton(
                iconSize: 30, // Bigger button
                padding: const EdgeInsets.symmetric(horizontal: 12),
                icon: const Icon(Icons.logout, color: Colors.white),
                tooltip: 'Logout',
                onPressed: () async {
                  DialogManager.customDialog(
                    context,
                    AppLocalizations.of(context)!.sureLogout,
                    color: null,
                    dialogType: DialogType.error,
                    buttonTitle: AppLocalizations.of(context)!.ok,
                    content: null,
                    onPressed: () {
                      SharedPrefs().isLoggedIn = false;
                      SharedPrefs().token = null;
                      SharedPrefs().userEmail = "";
                      SharedPrefs().userName = "";
                      SharedPrefs().clear(); // Clears all SharedPreferences
                      GoRouter.of(context).go('/'); // Go to home after logout
                    },
                    isDismissible: true,
                  );
                },
              ),
            ],
            // Apply the custom curve to the AppBar's flexible background
            flexibleSpace: ClipPath(
              clipper: BottomCurvedClipper(curveHeight: _curveHeight),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF1E3C72),
                      Color(0xFF2A5298),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  // Adjust the preferredSize to include the height of the curve
  Size get preferredSize => Size.fromHeight(kToolbarHeight + _curveHeight);
}
