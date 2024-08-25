import '../../../models/recent_activity.dart';

abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final String userName;
  final String profilePictureUrl;
  final int recipesCount;
  final int likesCount;
  final List<RecentActivity> recentActivity;

  ProfileLoaded({
    required this.userName,
    required this.profilePictureUrl,
    required this.recipesCount,
    this.likesCount = 0,
    this.recentActivity = const [],
  });
}

class ProfileError extends ProfileState {
  final String message;

  ProfileError(this.message);
}
