import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_api/amplify_api.dart';

import '../amplifyconfiguration.dart';

Future<void> configureAmplify() async {
  try {
    final authPlugin = AmplifyAuthCognito();
    final apiPlugin = AmplifyAPI();

    await Amplify.addPlugins([
      authPlugin,
      apiPlugin,
    ]);

    await Amplify.configure(amplifyconfig);
  } catch (e) {
    safePrint('Amplify already configured or failed: $e');
  }
}
