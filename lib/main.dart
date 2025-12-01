import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:animations/animations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:move_up/constants/app_colors.dart';
import 'package:move_up/screens/home_screen.dart';
import 'package:move_up/screens/splash_screen.dart';
import 'package:move_up/screens/login_screen.dart';
import 'package:move_up/screens/signup_screen.dart';
import 'package:move_up/screens/welcome_screen.dart';
import 'package:move_up/screens/maps_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Move Up',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.accentGreen),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      initialRoute: '/splash',
      onGenerateRoute: (settings) {
        WidgetBuilder builder;
        switch (settings.name) {
          case '/home':
            builder = (context) => const HomeScreen();
            break;
          case '/splash':
            builder = (context) => const SplashScreen();
            break;
          case '/login':
            builder = (context) => const LoginScreen();
            break;
          case '/maps':
            builder = (context) => const MapsScreen();
            break;
          case '/signup':
            builder = (context) => const SignUpScreen();
            break;
          case '/welcome':
            builder = (context) => const WelcomeScreen();
            break;
          default:
            builder = (context) => const Text('Error: Unknown route');
        }

        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) =>
              builder(context),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SharedAxisTransition(
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              transitionType: SharedAxisTransitionType.horizontal,
              child: child,
            );
          },
        );
      },
    );
  }
}
