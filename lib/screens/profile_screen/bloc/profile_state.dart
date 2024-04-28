abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final String userName;
  final String profilePictureUrl;
  final int cookbooksCount;
  final int recipesCount;
  final int likesCount;

  ProfileLoaded({
    required this.userName,
    required this.profilePictureUrl,
    this.cookbooksCount = 0,
    this.recipesCount = 0,
    this.likesCount = 0,
  });
}

class ProfileError extends ProfileState {
  final String message;

  ProfileError(this.message);
}
