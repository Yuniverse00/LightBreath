part of 'user_preferences_cubit.dart';

class UserPreferencesState{
  int pricePerCigarettes;
  int numberOfCigarettesPerPack;
  bool motionTracking;
  bool dailyTip;

  UserPreferencesState({required this.pricePerCigarettes, required this.numberOfCigarettesPerPack, required this.motionTracking, required this.dailyTip});

}
