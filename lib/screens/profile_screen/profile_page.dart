import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_recipe_app/main.dart';
import 'package:food_recipe_app/screens/authentication_screen/signin.dart';
import 'package:food_recipe_app/screens/profile_screen/bloc/profile_bloc.dart';
import 'package:food_recipe_app/screens/profile_screen/bloc/profile_event.dart';
import 'package:food_recipe_app/screens/profile_screen/bloc/profile_state.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:food_recipe_app/screens/authentication_screen/email_signup_page.dart';

import '../../models/recent_activity.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    // Load profile data when the page is initialized
    context.read<ProfileBloc>().add(LoadProfile());
    print("Dispatching FetchRecentActivity event");
    context.read<ProfileBloc>().add(FetchRecentActivity());
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final bool isAnonymous = user?.isAnonymous ?? true;

    return Scaffold(
      body: isAnonymous
          ? _buildGuestView(context)
          : BlocListener<ProfileBloc, ProfileState>(
              listener: (context, state) {
                if (state is ProfileError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(state.message),
                        duration: const Duration(seconds: 5)),
                  );
                }
              },
              child: BlocBuilder<ProfileBloc, ProfileState>(
                builder: (context, state) {
                  if (state is ProfileLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is ProfileLoaded) {
                    print(
                        "ProfileLoaded state with ${state.recentActivity.length} activities");
                    return _buildAuthenticatedView(context, state);
                  } else if (state is ProfileError) {
                    return Center(child: Text(state.message));
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
    );
  }

  Widget _buildGuestView(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                  'assets/guest_background.jpg'), // Add a background image
              fit: BoxFit.cover,
            ),
          ),
        ),
        Container(
          color: Colors.black.withOpacity(0.6),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.account_circle,
                    size: 100, color: Colors.white),
                const SizedBox(height: 20),
                Text(
                  'You are logged in as a guest.',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => showGuestOverlay(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  child: Text(
                    'Create an Account',
                    style: GoogleFonts.poppins(
                        fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAuthenticatedView(BuildContext context, ProfileLoaded state) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 200.0,
          floating: false,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: Image.network(
              state.profilePictureUrl.isNotEmpty
                  ? state.profilePictureUrl
                  : 'https://images.unsplash.com/photo-1420624226293-19b680e38dd6?q=80&w=2608&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
              fit: BoxFit.cover,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                final shouldLogout =
                    await showLogoutConfirmationDialog(context);
                if (shouldLogout == true) {
                  BlocProvider.of<ProfileBloc>(context, listen: false)
                      .add(SignOut());
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('You have been signed out.'),
                      duration: Duration(seconds: 5),
                    ),
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
                }
              },
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange[50]!, Colors.orange[100]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileHeader(
                      context, state.userName, state.profilePictureUrl),
                  const SizedBox(height: 20),
                  _buildStatisticsCard(state.recipesCount, state.likesCount),
                  const SizedBox(height: 20),
                  _buildRecentActivity(state.recentActivity),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileHeader(
      BuildContext context, String userName, String profilePictureUrl) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => _pickProfilePicture(context),
          child: CircleAvatar(
            radius: 50,
            backgroundImage: profilePictureUrl.isNotEmpty
                ? NetworkImage(profilePictureUrl)
                : null,
            child: profilePictureUrl.isEmpty
                ? Text(userName.isNotEmpty ? userName[0].toUpperCase() : '',
                    style: GoogleFonts.poppins(
                        fontSize: 32, fontWeight: FontWeight.bold))
                : null,
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(userName,
                  style: GoogleFonts.poppins(
                      fontSize: 24, fontWeight: FontWeight.bold)),
              Text('Food Enthusiast',
                  style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => _pickProfilePicture(context),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text('Change Profile Picture'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticsCard(int recipesCount, int likesCount) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(Icons.restaurant, 'Recipes', recipesCount),
            _buildStatItem(Icons.favorite, 'Likes', likesCount),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, dynamic value) {
    return Column(
      children: [
        Icon(icon, size: 30, color: Colors.orange),
        const SizedBox(height: 8),
        Text(label,
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey)),
        Text(value.toString(),
            style:
                GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildRecentActivity(List<RecentActivity> activities) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Recent Activity',
                style: GoogleFonts.playfairDisplaySc(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            if (activities.isEmpty)
              Text('No recent activity',
                  style: GoogleFonts.playfairDisplaySc(color: Colors.grey))
            else
              Column(
                children: activities
                    .map((activity) => _buildActivityItem(activity))
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(RecentActivity activity) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.circle, size: 12, color: Colors.orange),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${activity.action} ${activity.item}',
                  style: GoogleFonts.robotoSerif(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(DateFormat.yMMMd().add_jm().format(activity.timestamp),
                    style: GoogleFonts.montserrat(
                        fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        ],
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
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  Future<bool?> showLogoutConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text('Confirm Logout',
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold, color: Colors.orange[800])),
          content: Text('Are you sure you want to log out?',
              style: GoogleFonts.poppins()),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel',
                  style: GoogleFonts.poppins(color: Colors.grey[600])),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[800],
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('Logout',
                  style: GoogleFonts.poppins(color: Colors.white)),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );
  }
}
