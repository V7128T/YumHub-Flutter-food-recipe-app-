abstract class ProfileEvent {}

class LoadProfile extends ProfileEvent {}

class SignOut extends ProfileEvent {}

class UpdateProfilePicture extends ProfileEvent {
  final String imagePath;

  UpdateProfilePicture(this.imagePath);
}

class FetchRecipesCount extends ProfileEvent {}

class UpdateRecipesCount extends ProfileEvent {
  final int count;

  UpdateRecipesCount(this.count);
}

class FetchRecentActivity extends ProfileEvent {}
