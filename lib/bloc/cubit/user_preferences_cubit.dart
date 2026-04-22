
import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'user_preferences_state.dart';

class UserPreferencesCubit extends Cubit<UserPreferencesState> {
  String? username;
  Map? _userPreferences;
  SharedPreferences? _prefs;
  UserPreferencesCubit()
      : super(UserPreferencesState(
            pricePerCigarettes: 0,
            numberOfCigarettesPerPack: 0,
            motionTracking: true,
            dailyTip: true));

  void getUserPreferences() async {
    if (username == null ){
      final user = await Amplify.Auth.getCurrentUser();
      username = user.username;
      _prefs = await SharedPreferences.getInstance();
    }
    final String? userPreferences = _prefs!.getString(username!);
    safePrint(userPreferences);
    if (userPreferences != null) {
      _userPreferences = jsonDecode(userPreferences);
      emit(UserPreferencesState(
          pricePerCigarettes: _userPreferences!['price_per_cigarettes'],
          numberOfCigarettesPerPack:
              _userPreferences!['number_of_cigarettes_per_pack'],
          motionTracking: _userPreferences!['motion_tracking'],
          dailyTip: _userPreferences!['daily_tip']));
    } else {
      var newPreference = {
        'price_per_cigarettes': 0,
        'number_of_cigarettes_per_pack': 0,
        'motion_tracking': true,
        'daily_tip': true,
      };

      await _prefs!.setString(username!, jsonEncode(newPreference));

      _userPreferences = newPreference;
    }
  }

  void saveUserPreference(int pricePerCigarettes, int numberOfCigarettesPerPack,
      bool motionTracking, bool dailyTip) async {
    var newPreference = {
      'price_per_cigarettes': pricePerCigarettes,
      'number_of_cigarettes_per_pack': numberOfCigarettesPerPack,
      'motion_tracking': motionTracking,
      'daily_tip': dailyTip,
    };

    await _prefs!.setString(username!, jsonEncode(newPreference)).then((value) => {getUserPreferences()});


  }
}
