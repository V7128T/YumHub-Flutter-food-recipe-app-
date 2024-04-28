import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_recipe_app/main.dart';
import 'package:food_recipe_app/screens/authentication_screen/signin.dart';
import 'package:food_recipe_app/screens/profile_screen/bloc/profile_bloc.dart';
import 'package:food_recipe_app/screens/profile_screen/bloc/profile_event.dart';
import 'package:food_recipe_app/screens/profile_screen/bloc/profile_state.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:food_recipe_app/screens/authentication_screen/email_signup_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final bool isAnonymous = user?.isAnonymous ?? true;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: GoogleFonts.chivo(
            textStyle: const TextStyle(
              fontSize: 25.0,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
          if (!isAnonymous)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                BlocProvider.of<ProfileBloc>(context, listen: false)
                    .add(SignOut());
                Builder(
                  builder: (context) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('You have been signed out.'),
                        duration: Duration(seconds: 3),
                      ),
                    );
                    return const SizedBox.shrink();
                  },
                );
                Future.delayed(
                  const Duration(seconds: 2),
                  () {
                    navKey.currentState?.pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (context) => const LoginPage()),
                      (route) => false,
                    );
                  },
                );
              },
            ),
        ],
      ),
      body: isAnonymous
          ? Stack(
              children: [
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'You are logged in as a guest.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            showGuestOverlay(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                          ),
                          child: const Text('Create an Account'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : BlocBuilder<ProfileBloc, ProfileState>(
              builder: (context, state) {
                if (state is ProfileLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is ProfileLoaded) {
                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildProfileHeader(
                            context, state.userName, state.profilePictureUrl),
                        _buildProfileSections(
                          state.cookbooksCount,
                          state.recipesCount,
                          state.likesCount,
                        ),
                      ],
                    ),
                  );
                } else if (state is ProfileError) {
                  return Center(child: Text(state.message));
                } else {
                  return Container();
                }
              },
            ),
    );
  }

  void showGuestOverlay(BuildContext context) {
    showMaterialModalBottomSheet(
      context: context,
      builder: (context) => SingleChildScrollView(
        controller: ModalScrollController.of(context),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.info,
                color: Colors.orange,
                size: 48,
              ),
              const SizedBox(height: 20),
              const Text(
                'You are currently logged in as a guest.',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                'To access all features and personalize your experience, please create an account.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Future.delayed(
                    const Duration(seconds: 2),
                    () {
                      navKey.currentState?.pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (context) => const EmailSignUp()),
                        (route) => false,
                      );
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Text(
                  'Create an Account',
                  style: GoogleFonts.roboto(
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(
      context, String userName, String profilePictureUrl) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => _pickProfilePicture(context),
            child: CircleAvatar(
              backgroundImage: profilePictureUrl.isNotEmpty
                  ? NetworkImage(profilePictureUrl)
                  : null,
              radius: 48,
              child: profilePictureUrl.isEmpty
                  ? Text(userName.isNotEmpty ? userName[0].toUpperCase() : '')
                  : null,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            userName,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('Community member'),
        ],
      ),
    );
  }

  void _pickProfilePicture(BuildContext context) async {
    final ImagePicker _picker = ImagePicker();

    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        BlocProvider.of<ProfileBloc>(context)
            .add(UpdateProfilePicture(image.path));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image: $e'),
        ),
      );
    }
  }

  Widget _buildProfileSections(
    int cookbooksCount,
    int recipesCount,
    int likesCount,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildProfileSection(Icons.book, 'Cookbooks', cookbooksCount),
        _buildProfileSection(Icons.restaurant, 'Recipes', recipesCount),
        _buildProfileSection(Icons.favorite, 'Likes', likesCount),
      ],
    );
  }

  Widget _buildProfileSection(IconData icon, String title, int count) {
    return Column(
      children: [
        Icon(icon, size: 48),
        const SizedBox(height: 8),
        Text(title),
        const SizedBox(height: 4),
        Text(count.toString()),
      ],
    );
  }
}
