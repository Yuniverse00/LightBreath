import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:bloc/bloc.dart';
import 'package:sense2quit/authCredentials.dart';

import '../../constants.dart';

part 'amplify_auth_cubit_state.dart';

class AmplifyAuthCubit extends Cubit<AmplifyAuthState> {
  final authCredentials =
      AuthCredentials(email: '', username: '', password: '');

  AmplifyAuthCubit()
      : super(AmplifyAuthState(status: Constants.INITIAL, errorMessage: ""));

  // final amplifyUtils = AmplifyUtils();

  Future<void> signInUser(
    String username,
    String password,
  ) async {
    authCredentials.username = username;
    authCredentials.password = password;
    try {
      final result = await Amplify.Auth.signIn(
        username: username,
        password: password,
      );
      await _handleSignInResult(result);
    } on AuthException catch (e) {
      safePrint('Error signing in: ${e.message}');
      emit(AmplifyAuthState(
          status: Constants.ERROR_MESSAGE_SET, errorMessage: e.message));
    }
  }

  Future<void> _handleSignInResult(SignInResult result) async {
    switch (result.nextStep.signInStep) {
      case AuthSignInStep.confirmSignInWithSmsMfaCode:
        final codeDeliveryDetails = result.nextStep.codeDeliveryDetails!;
        _handleCodeDelivery(codeDeliveryDetails);
        break;
      case AuthSignInStep.confirmSignInWithNewPassword:
        safePrint('Enter a new password to continue signing in');
        break;
      case AuthSignInStep.confirmSignInWithCustomChallenge:
        final parameters = result.nextStep.additionalInfo;
        final prompt = parameters['prompt']!;
        safePrint(prompt);
        break;
      case AuthSignInStep.resetPassword:
        // final resetResult = await Amplify.Auth.resetPassword(
        //   username: username,
        // );
        // await _handleResetPasswordResult(resetResult);
        break;
      case AuthSignInStep.confirmSignUp:
        // Resend the sign up code to the registered device.
        // final resendResult = await Amplify.Auth.resendSignUpCode(
        //   username: username,
        // );
        // _handleCodeDelivery(resendResult.codeDeliveryDetails);
        break;
      case AuthSignInStep.done:
        safePrint('Sign in is complete');
        emit(AmplifyAuthState(
            status: Constants.LOGIN_SUCCEEDED, errorMessage: ''));
        break;
      default:
      break;
    }
  }

  void _handleCodeDelivery(AuthCodeDeliveryDetails codeDeliveryDetails) {
    safePrint(
      'A confirmation code has been sent to ${codeDeliveryDetails.destination}. '
      'Please check your ${codeDeliveryDetails.deliveryMedium.name} for the code.',
    );
    emit(AmplifyAuthState(
        status: Constants.REGISTER_SUCCEEDED, errorMessage: ''));
  }

  Future<void> autoSignIn() async {
    await signInUser(authCredentials.username, authCredentials.password);
  }

  Future<void> signUpUser({
    required String username,
    required String password,
    required String email,
    String? phoneNumber,
  }) async {
    authCredentials.username = username;
    authCredentials.password = password;
    authCredentials.email = email;
    try {
      final userAttributes = {
        AuthUserAttributeKey.email: email,
        if (phoneNumber != null) AuthUserAttributeKey.phoneNumber: phoneNumber,
        // additional attributes as needed
      };
      final result = await Amplify.Auth.signUp(
        username: username,
        password: password,
        options: SignUpOptions(
          userAttributes: userAttributes,
        ),
      );
      await _handleSignUpResult(result);
    } on AuthException catch (e) {
      safePrint('Error signing up user: ${e.message}');
      emit(AmplifyAuthState(
          status: Constants.ERROR_MESSAGE_SET, errorMessage: e.message));
    }
  }

  Future<void> confirmUser({
    required String confirmationCode,
  }) async {
    try {
      final result = await Amplify.Auth.confirmSignUp(
        username: authCredentials.username,
        confirmationCode: confirmationCode,
      );
      // Check if further confirmations are needed or if
      // the sign up is complete.
      await _handleSignUpResult(result);
    } on AuthException catch (e) {
      safePrint('Error confirming user: ${e.message}');
      safePrint(e.message);
      emit(AmplifyAuthState(
          status: Constants.ERROR_MESSAGE_SET, errorMessage: e.message));
    }
  }

  Future<void> _handleSignUpResult(SignUpResult result) async {
    switch (result.nextStep.signUpStep) {
      case AuthSignUpStep.confirmSignUp:
        final codeDeliveryDetails = result.nextStep.codeDeliveryDetails!;
        _handleCodeDelivery(codeDeliveryDetails);
        break;
      case AuthSignUpStep.done:
        safePrint('Sign up is complete');
        emit(AmplifyAuthState(
            status: Constants.CONFIRM_SUCCEEDED, errorMessage: ''));
        break;
    }
  }

  Future<void> resetPassword(String username) async {
    try {
      final result = await Amplify.Auth.resetPassword(
        username: username,
      );
      authCredentials.username = username;
      await _handleResetPasswordResult(result);
    } on AuthException catch (e) {
      safePrint('Error resetting password: ${e.message}');
      emit(AmplifyAuthState(
          status: Constants.ERROR_MESSAGE_SET, errorMessage: e.message));
    }
  }

  Future<void> _handleResetPasswordResult(ResetPasswordResult result) async {
    switch (result.nextStep.updateStep) {
      case AuthResetPasswordStep.confirmResetPasswordWithCode:
        final codeDeliveryDetails = result.nextStep.codeDeliveryDetails!;
        _handleCodeDelivery(codeDeliveryDetails);
        emit(AmplifyAuthState(
            status: Constants.CONFIRMATION_REQUIRED, errorMessage: ''));
        break;
      case AuthResetPasswordStep.done:
        safePrint('Successfully reset password');
        break;
    }
  }

  Future<void> confirmResetPassword({
    // required String username,
    required String newPassword,
    required String confirmationCode,
  }) async {
    try {
      final result = await Amplify.Auth.confirmResetPassword(
        username: authCredentials.username,
        newPassword: newPassword,
        confirmationCode: confirmationCode,
      );
      safePrint('Password reset complete: ${result.isPasswordReset}');
      emit(AmplifyAuthState(
          status: Constants.RESET_SUCCEEDED, errorMessage: ''));
    } on AuthException catch (e) {
      safePrint('Error resetting password: ${e.message}');
      emit(AmplifyAuthState(
          status: Constants.ERROR_MESSAGE_SET, errorMessage: e.message));
    }
  }

  Future<void> updatePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      await Amplify.Auth.updatePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
      emit(AmplifyAuthState(
          status: Constants.UPDATE_SUCCEEDED, errorMessage: ''));
    } on AuthException catch (e) {
      safePrint('Error updating password: ${e.message}');
      emit(AmplifyAuthState(
          status: Constants.ERROR_MESSAGE_SET, errorMessage: e.message));
    }
  }

  Future<void> signOutCurrentUser() async {
    final result = await Amplify.Auth.signOut();
    if (result is CognitoCompleteSignOut) {
      safePrint('Sign out completed successfully');
      emit(AmplifyAuthState(
          status: Constants.LOGOUT_SUCCEEDED, errorMessage: ''));
    } else if (result is CognitoFailedSignOut) {
      safePrint('Error signing user out: ${result.exception.message}');
      emit(AmplifyAuthState(
          status: Constants.ERROR_MESSAGE_SET,
          errorMessage: result.exception.message));
    }
  }
}
