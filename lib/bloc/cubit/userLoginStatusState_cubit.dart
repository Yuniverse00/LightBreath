part of 'userLoginStatus_cubit.dart';

class UserLoginStatusState {
  bool userLoggedIn;

  UserLoginStatusState({
    required this.userLoggedIn
  });

  
}

class Loading extends UserLoginStatusState{
  Loading({required super.userLoggedIn});

}
