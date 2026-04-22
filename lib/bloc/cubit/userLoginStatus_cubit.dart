import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:bloc/bloc.dart';


part 'userLoginStatusState_cubit.dart';


class UserLoginStatusCubit extends Cubit<UserLoginStatusState> {
  UserLoginStatusCubit() : super(Loading(userLoggedIn: false));

  Future<void> getAuthStatus() async {
    final AuthSession res = await Amplify.Auth.fetchAuthSession();
    emit(UserLoginStatusState(userLoggedIn: res.isSignedIn));
  }
  
}
