import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_datastore/amplify_datastore.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'amplifyconfiguration.dart';
import 'bloc/cubit/amplify_auth_cubit.dart';
import 'package:sense2quit/bloc/cubit/activity_cubit.dart';
import 'package:sense2quit/bloc/cubit/amplify_data_store_cubit.dart';
import 'package:sense2quit/bloc/cubit/ble_connectivity_cubit.dart';
import 'package:sense2quit/bloc/cubit/faqs_data_cubit.dart';
import 'package:sense2quit/bloc/cubit/tips_cubit.dart';
import 'package:sense2quit/bloc/cubit/userLoginStatus_cubit.dart';
import 'package:sense2quit/bloc/cubit/user_preferences_cubit.dart';

import 'games/pacman/pacman.dart';
import 'models/ModelProvider.dart';
import 'pages/ProfilePage.dart';
import 'pages/TargetSettingPage.dart';
import 'pages/check_in_page.dart';
import 'pages/communityPage.dart';
import 'pages/confirmResetPage.dart';
import 'pages/confirmSignUpPage.dart';
import 'pages/dataTransferPage.dart';
import 'pages/faqsPage.dart';
import 'pages/family_support_page.dart';
import 'pages/gamesPage.dart';
import 'pages/homePage.dart';
import 'pages/loginPage.dart';
import 'pages/registerPage.dart';
import 'pages/resetPasswordPage.dart';
import 'pages/settingPage.dart';
import 'pages/stats_page.dart';
import 'pages/tipsPage.dart';

// ==================== main ====================
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isAmplifyConfigured = false;

  @override
  void initState() {
    super.initState();
    _configureAmplify();
  }

  Future<void> _configureAmplify() async {
    try {
      final auth = AmplifyAuthCognito();
      final datastorePlugin = AmplifyDataStore(
        modelProvider: ModelProvider.instance,
      );
      final api = AmplifyAPI();

      safePrint('Starting Amplify configuration...');
      await Amplify.addPlugins([datastorePlugin, api, auth]);
      safePrint('Plugins added, configuring Amplify...');

      await Amplify.configure(amplifyconfig);
      setState(() => _isAmplifyConfigured = true);
      safePrint('Successfully configured Amplify');
    } on Exception catch (e) {
      safePrint('An error occurred configuring Amplify: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => UserLoginStatusCubit()..getAuthStatus(),
        ),
        BlocProvider(
          create: (context) => AmplifyAuthCubit(),
        ),
        BlocProvider(
          create: (context) => AmplifyDataStoreCubit()..getUsername(),
        ),

        // ✅ 改动点：把 AmplifyDataStoreCubit 注入给 BLE cubit
        BlocProvider(
          create: (context) => BleConnectivityCubit(
            amplifyDataStoreCubit: BlocProvider.of<AmplifyDataStoreCubit>(context),
          ),
        ),

        BlocProvider(
          create: (context) => UserPreferencesCubit()..getUserPreferences(),
        ),
        BlocProvider(
          create: (context) => FaqsDataCubit()..getFaqData(),
        ),
        BlocProvider(
          create: (context) => TipsCubit()..getTipsVideoData(),
        ),

        BlocProvider(
          create: (context) => ActivityCubit(
            bleConnectivityCubit: BlocProvider.of<BleConnectivityCubit>(context),
            amplifyDataStoreCubit: BlocProvider.of<AmplifyDataStoreCubit>(context),
          ),
        ),
      ],
      child: MaterialApp(
        home: _isAmplifyConfigured
            ? BlocConsumer<UserLoginStatusCubit, UserLoginStatusState>(
          listener: (context, state) {},
          builder: (context, state) {
            if (state.userLoggedIn) {
              return const Home();
            } else if (state is Loading) {
              return const Center(child: CircularProgressIndicator());
            }
            return const LoginPage();
          },
        )
            : const Center(child: CircularProgressIndicator()),
        routes: {
          '/home': (context) => const Home(),
          '/login': (context) => const LoginPage(),
          '/register': (context) => const RegisterPage(),
          '/confirm': (context) => const ConfirmSignUp(),
          '/resetPassword': (context) => const ResetPassword(),
          '/confirmReset': (context) => const ConfirmReset(),
          '/dataTransferPage': (context) => const DataTransfer(),
          '/settingPage': (context) => const SettingPage(),
          '/gamesPage': (context) => const GamesPage(),
          '/faqsPage': (context) => const FaqsPage(),
          '/pacman': (context) => const Pacman(),
          '/tipsPage': (context) => const TipsPage(),
          '/profilePage': (context) => const ProfilePage(),
          '/targetPage': (context) => const TargetSettingPage(),
          '/checkInPage': (context) => const CheckInPage(),
          '/statsPage': (context) => const StatsPage(),
          '/familySupport': (context) => const FamilySupportPage(),
          '/communityPage': (context) => const CommunityPage(),
        },
      ),
    );
  }
}