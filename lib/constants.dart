class Constants {
  //  static const  double SCALE_ACC = 5.0f;
  static const int SMOKING = -1;
  static const int TIMEOFSMOKING = -2;

  static const int UPLOADREADY = -3;
  // result code
  static const int LOGIN_SUCCEEDED = 0;
  static const int REGISTER_SUCCEEDED = 1;
  static const int CONFIRM_SUCCEEDED = 2;
  static const int LOGOUT_SUCCEEDED = 3;

  // login error
  static const int ERR_USERNAME_OR_PASSWORD = 100;
  static const int ERR_USER_DOES_NOT_EXIST = 101;
  static const int ERR_MISSING_USERNAME = 102;
  static const int ERR_INTERNET_CONNECTION = 103;
  static const int ERR_NOT_CONFIRMED = 104;

  // register error
  static const int ERR_PASSWORD_NOT_MATCH = 200;
  static const int ERR_PARAMETER = 201;
  static const int ERR_USER_EXISTS = 202;
  static const int ERR_CODE_MISMATCH = 203;

  // reset password
  static const int CONFIRMATION_REQUIRED = 300;
  static const int RESET_SUCCEEDED = 301;

  // update password
  static const int UPDATE_SUCCEEDED = 501;

  // error message set
  static const int ERROR_MESSAGE_SET = 400;

  // unknown error
  static const int ERR_UNKNOWN = 1000;


  //initial
  static const int INITIAL = 99;
}
