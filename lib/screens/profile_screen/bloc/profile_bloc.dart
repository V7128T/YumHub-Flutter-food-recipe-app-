import 'dart:async';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_recipe_app/auth_methods/firebaseFunctions.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ProfileBloc() : super(ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<SignOut>(_onSignOut);
    on<UpdateProfilePicture>(_onUpdateProfilePicture);
    on<FetchRecipesCount>(_onFetchRecipesCount);
    on<UpdateRecipesCount>(_onUpdateRecipesCount);
  }

  FutureOr<void> _onLoadProfile(
      LoadProfile event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        final DocumentSnapshot snapshot =
            await _firestore.collection('users').doc(user.uid).get();
        final userData = snapshot.data() as Map<String, dynamic>?;
        if (userData != null) {
          final userName = userData['name'] as String?;
          final recipesCount = userData['recipes_count'] as int? ?? 0;
          final likesCount = userData['likes_count'] as int? ?? 0;
          emit(ProfileLoaded(
            userName: userName ?? '',
            profilePictureUrl: userData['profile_picture_url'] ?? '',
            recipesCount: recipesCount,
            likesCount: likesCount,
          ));
        } else {
          emit(ProfileError('User data not found'));
        }
      } else {
        emit(ProfileError('User not signed in'));
      }
    } catch (e) {
      emit(ProfileError('Failed to load profile: $e'));
    }
  }

  FutureOr<void> _onSignOut(SignOut event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    try {
      await _auth.signOut();
      await GoogleSignIn().signOut();
      emit(ProfileInitial());
    } catch (e) {
      emit(ProfileError('Failed to sign out: $e'));
    }
  }

  FutureOr<void> _onUpdateProfilePicture(
      UpdateProfilePicture event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        final Reference storageRef = FirebaseStorage.instance
            .ref()
            .child('profile_pictures/${user.uid}/profile.jpg');

        await storageRef.putFile(File(event.imagePath));
        final String downloadUrl = await storageRef.getDownloadURL();

        await _firestore
            .collection('users')
            .doc(user.uid)
            .update({'profile_picture_url': downloadUrl});

        final DocumentSnapshot userSnapshot =
            await _firestore.collection('users').doc(user.uid).get();
        final userData = userSnapshot.data() as Map<String, dynamic>?;

        if (userData != null) {
          final userName = userData['name'] as String?;
          final recipesCount = userData['recipes_count'] as int? ?? 0;
          final likesCount = userData['likes_count'] as int? ?? 0;

          emit(ProfileLoaded(
            userName: userName ?? '',
            profilePictureUrl: downloadUrl,
            recipesCount: recipesCount,
            likesCount: likesCount,
          ));
        } else {
          emit(ProfileError('User data not found'));
        }
      } else {
        emit(ProfileError('User not signed in'));
      }
    } on FirebaseException catch (e) {
      emit(ProfileError('Firebase error: ${e.message}'));
    } catch (e) {
      emit(ProfileError('Failed to update profile picture: $e'));
    }
  }

  Future<void> _onFetchRecipesCount(
      FetchRecipesCount event, Emitter<ProfileState> emit) async {
    if (state is ProfileLoaded) {
      final currentState = state as ProfileLoaded;
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final recipesCount =
            await FirestoreServices.getUserRecipesCount(user.uid);
        emit(ProfileLoaded(
          userName: currentState.userName,
          profilePictureUrl: currentState.profilePictureUrl,
          recipesCount: recipesCount,
          likesCount: currentState.likesCount,
        ));
      }
    }
  }

  Future<void> _onUpdateRecipesCount(
      UpdateRecipesCount event, Emitter<ProfileState> emit) async {
    if (state is ProfileLoaded) {
      final currentState = state as ProfileLoaded;
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'recipes_count': event.count,
        });
        emit(ProfileLoaded(
          userName: currentState.userName,
          profilePictureUrl: currentState.profilePictureUrl,
          recipesCount: event.count,
          likesCount: currentState.likesCount,
        ));
      }
    }
  }
}
