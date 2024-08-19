import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_recipe_app/screens/nav/bottom_nav_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:food_recipe_app/screens/authentication_screen/signin.dart';
import 'package:food_recipe_app/models/user_ingredient_list.dart';
import 'screens/profile_screen/bloc/profile_bloc.dart';
import 'screens/profile_screen/bloc/profile_event.dart';
import 'screens/welcome_screen/welcome_screen.dart';
import 'screens/welcome_screen/splash_screen.dart';
import 'custom_colors/app_colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseDatabase.instance.databaseURL =
      'https://yumhub-483b7-default-rtdb.asia-southeast1.firebasedatabase.app';

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserIngredientList()),
        BlocProvider(create: (_) => ProfileBloc()..add(LoadProfile())),
      ],
      child: const MyApp(),
    ),
  );
}

final GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.customPrimary),
      ),
      navigatorKey: navKey,
      title: 'YumHub',
      routes: {
        '/signin': (context) => const LoginPage(),
      },
      home: const SplashScreenWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SplashScreenWrapper extends StatefulWidget {
  const SplashScreenWrapper({super.key});

  @override
  _SplashScreenWrapperState createState() => _SplashScreenWrapperState();
}

class _SplashScreenWrapperState extends State<SplashScreenWrapper> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  _navigateToHome() async {
    await Future.delayed(
        const Duration(seconds: 3)); // Adjust the duration as needed
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const AppContent()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreen(); // Your custom SplashScreen widget
  }
}

class AppContent extends StatelessWidget {
  const AppContent({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          return const BottomNavView();
        } else {
          return const WelcomeScreen();
        }
      },
    );
  }
}
