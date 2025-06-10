import 'package:app_links/app_links.dart';
import 'package:complaintsapp/AppClient/Services/_shared_prefs_helper.dart';
import 'package:complaintsapp/Ui/Authentication_Screens/ConfirmEmail/ConfirmEmailScreen.dart';
import 'package:complaintsapp/Ui/Authentication_Screens/Login/Login_Page.dart';
import 'package:complaintsapp/Ui/Authentication_Screens/Register/Register.dart';
import 'package:complaintsapp/Ui/home/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterLocalization.instance.ensureInitialized();
  try {
    await SharedPrefs().init();
  } catch (e) {
    print('Error initializing SharedPrefs: $e');
  }
  runApp(const MyApp());
}

Locale _locale = SharedPrefs().language == 'ar' ? const Locale('ar') : const Locale('en');

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
  static void setLocale(BuildContext context, Locale newLocale) async {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.changeLanguage(newLocale);
  }
}

class _MyAppState extends State<MyApp> {
  Locale? _locale = SharedPrefs().language == 'ar' ? const Locale('ar') : const Locale('en');

  @override
  void initState() {
    super.initState();
    _locale = SharedPrefs().language == 'ar' ? const Locale('ar') : const Locale('en');
    // _handleIncomingLinks();
  }

  // void _handleIncomingLinks() async {
  //   final appLinks = AppLinks();

  //   // Handle initial link if app was opened via deep link
  //   final Uri? initialLinkString = await appLinks.getInitialLink();
  //   if (initialLinkString != null) {
  //     final Uri initialUri = initialLinkString;
  //     initDeepLink(initialUri);
  //   }

  //   // Listen to link changes (if app already opened)
  //   appLinks.uriLinkStream.listen((Uri uri) {
  //     initDeepLink(uri);
  //   });
  // }

  // Future<void> initDeepLink(Uri uri) async {
  //   try {
  //     print("Received deep link: $uri");

  //     if (uri.scheme == 'complaintsapp' && uri.host == 'confirm-email') {
  //       final email = uri.queryParameters['email'];
  //       final token = uri.queryParameters['token'];

  //       if (email != null && token != null) {
  //         // Navigate to confirmation page or handle token
  //         Navigator.pushNamed(context, '/confirm-email', arguments: {
  //           'email': email,
  //           'token': token,
  //         });
  //       }
  //     }
  //   } catch (e) {
  //     print("Error handling deep link: $e");
  //   }
  // }

  changeLanguage(Locale locale) {
    setState(() {
      _locale = SharedPrefs().language == 'ar' ? const Locale('ar') : const Locale('en');
    });
  }

  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      supportedLocales: [
        Locale('en'),
        Locale('ar'),
      ],
      locale: _locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      title: 'شكاوي',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}

final GoRouter _router = GoRouter(
  redirect: authRedirect,
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      pageBuilder: (BuildContext context, GoRouterState state) {
        return _buildTransitionPage(const LoginPage(), 'fade');
      },
      routes: <RouteBase>[
        GoRoute(
          path: '/register',
          pageBuilder: (BuildContext context, GoRouterState state) {
            return _buildTransitionPage(const RegisterPage(), 'fade');
          },
        ),
        GoRoute(
          path: '/confirm-email',
          builder: (context, state) {
            final email = state.uri.queryParameters['email'];
            final token = state.uri.queryParameters['token'];
            return ConfirmEmailScreen(passed_email  : email, token: token);
          },
        ),
      ],
    ),
    GoRoute(
      path: '/home',
      pageBuilder: (BuildContext context, GoRouterState state) {
        return _buildTransitionPage(const HomeScreen(), 'slide');
      },
    ),
  ],
);

CustomTransitionPage _buildTransitionPage(Widget child, String animationType) {
  return CustomTransitionPage(
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0); // slide from right
      const end = Offset.zero;
      const curve = Curves.easeInOut;

      final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      final offsetAnimation = animation.drive(tween);

      if (animationType == 'fade') {
        return FadeTransition(opacity: animation, child: child);
      } else if (animationType == 'slide') {
        return SlideTransition(position: offsetAnimation, child: child);
      }
      return child; // Default case, no transition
    },
  );
}

String? authRedirect(BuildContext context, GoRouterState state) {
  final isLoggedIn = SharedPrefs().isLoggedIn;
  final token = SharedPrefs().token;

  final isAuth = isLoggedIn && token != null && token.isNotEmpty;

  final goingToLogin = state.uri.toString() == '/' || state.uri.toString() == '/register' || state.uri.toString() == '/confirm-email';
  if (!isAuth && !goingToLogin) {
    // Not logged in, trying to access protected route
    return '/';
  }

  if (isAuth && goingToLogin) {
    // Already logged in, redirect from login to home
    return '/home';
  }

  return null; // no redirection
}
