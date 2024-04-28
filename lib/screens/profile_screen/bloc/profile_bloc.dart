import 'dart:async';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
          final cookbooksCount = userData['cookbooks_count'] as int? ?? 0;
          final recipesCount = userData['recipes_count'] as int? ?? 0;
          final likesCount = userData['likes_count'] as int? ?? 0;
          emit(ProfileLoaded(
            userName: userName ?? '',
            profilePictureUrl: userData['profile_picture_url'] ?? '',
            cookbooksCount: cookbooksCount,
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
            .child('profile_pictures/${user.uid}');
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
          final cookbooksCount = userData['cookbooks_count'] as int? ?? 0;
          final recipesCount = userData['recipes_count'] as int? ?? 0;
          final likesCount = userData['likes_count'] as int? ?? 0;

          emit(ProfileLoaded(
            userName: userName ?? '',
            profilePictureUrl: downloadUrl,
            cookbooksCount: 5,
            recipesCount: 10,
            likesCount: 20,
          ));
        } else {
          emit(ProfileError('User data not found'));
        }
      } else {
        emit(ProfileError('User not signed in'));
      }
    } catch (e) {
      emit(ProfileError('Failed to update profile picture: $e'));
    }
  }
}
