import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:food_recipe_app/screens/nav/bottom_nav_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:food_recipe_app/custom_colors/app_colors.dart';
import 'package:food_recipe_app/screens/authentication_screen/signin.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:food_recipe_app/screens/home_screen/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  ///Commenting it out for a time being
  // var dir = await getApplicationDocumentsDirectory();
  // await Hive.init(dir.path);
  //await Hive.openBox('Favorite');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: BottomNavView(),
//     );
//   }
// }
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    //debugInvertOversizedImages = true;

    return MaterialApp(
      title: 'YumHub',
      routes: {
        '/signin': (context) => const LoginPage(),
      },
      home: Builder(
        builder: (context) {
          return Scaffold(
            body: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                          'assets/pizza-pizza-hut-cooking-kitchen.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(
                  color: Colors.black.withOpacity(0.5),
                  // Dim the image with a semi-transparent black overlay
                  child: SafeArea(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 8.0),
                                Align(
                                  alignment: Alignment.center,
                                  child: RichText(
                                    textAlign: TextAlign.center,
                                    text: TextSpan(
                                      style: GoogleFonts.chivo(
                                        textStyle: const TextStyle(
                                          fontSize: 32.0,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      children: const [
                                        TextSpan(text: 'Welcome to YumHub!'),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16.0),
                                Center(
                                  child: Text(
                                    "Start your culinary journey now! Explore recipes, plan meals, and shop smarter with our app. Let's get cooking!",
                                    style: GoogleFonts.chivo(
                                      textStyle: const TextStyle(
                                        fontSize: 16.0,
                                        color: Colors.white,
                                      ),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16.0),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    // Add your logic for finding new recipes
                                    Navigator.push(
                                        context,
                                        PageTransition(
                                            type: PageTransitionType.fade,
                                            child: BottomNavView()));
                                  },
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: const Color(0xfffe8574),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16.0),
                                  ),
                                  child: Text(
                                    'Find new recipes',
                                    style: GoogleFonts.chivo(
                                      textStyle: const TextStyle(
                                        fontSize: 15.0,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      "Already have an account?",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 15.0),
                                    ),
                                    const SizedBox(
                                      width: 5.0,
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            PageTransition(
                                                type: PageTransitionType.fade,
                                                child: const LoginPage()));
                                      },
                                      child: const Text(
                                        "Login",
                                        style: TextStyle(
                                            color: AppColors.defaultRed,
                                            fontSize: 15.0,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
