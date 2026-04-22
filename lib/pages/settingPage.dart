import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:sense2quit/bloc/cubit/amplify_auth_cubit.dart';
import 'package:sense2quit/bloc/cubit/user_preferences_cubit.dart';
import 'package:sense2quit/constants.dart';
import 'package:sense2quit/widgets/loginTextField.dart';
import 'package:sense2quit/widgets/numberinputField.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  final pricePerCigarettesController = TextEditingController();
  final numCigarettesPerPackController = TextEditingController();
  final newPasswordController = TextEditingController();
  final passwordController = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _authListener();
  }

  void _authListener() {
    BlocListener<AmplifyAuthCubit, AmplifyAuthState>(
      listener: (BuildContext context, AmplifyAuthState state) {
        Navigator.of(context).pop();
        if (state.status == Constants.ERROR_MESSAGE_SET) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.errorMessage),
            backgroundColor: Colors.red,
          ));
        }
        if (state.status == Constants.UPDATE_SUCCEEDED) {
          safePrint('Update succeeded');
          Navigator.of(context).pop();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserPreferencesCubit, UserPreferencesState>(
      listener: (context, state) {
        // TODO: implement listener
      },
      builder: (context, state) {
        final String? username =
            BlocProvider.of<UserPreferencesCubit>(context).username;
        var dailyTip = state.dailyTip;
        var motionTracking = state.motionTracking;
        var pricePerCigarettes = state.pricePerCigarettes;
        var numberOfCigarettesPerPack = state.numberOfCigarettesPerPack;
        return BlocConsumer<AmplifyAuthCubit, AmplifyAuthState>(
          listener: (context, authstate) {
            // Navigator.of(context).pop();
            if (authstate.status == Constants.ERROR_MESSAGE_SET) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(authstate.errorMessage),
                backgroundColor: Colors.red,
              ));
            }
            if (authstate.status == Constants.UPDATE_SUCCEEDED) {
              safePrint('Update succeeded');
              Navigator.of(context).pop();
            }
          },
          builder: (context, Authstate) {
            return Scaffold(
              appBar: AppBar(
                centerTitle: true,
                title: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        "lib/assets/settings.png",
                        fit: BoxFit.contain,
                        height: 50,
                        width: 50,
                      ),
                      const Text(
                        "Setting",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold),
                      )
                    ]),
              ),
              body: SafeArea(
                child: SingleChildScrollView(
                  child: Center(
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 20,
                        ),
                        Row(children: [
                          const Padding(padding: EdgeInsets.only(left: 25)),
                          Text(
                            "Hi, ${BlocProvider.of<UserPreferencesCubit>(context).username}, here are your app settings.",
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ]),
                        const SizedBox(
                          height: 20,
                        ),
                        const Row(
                          children: [
                            Padding(padding: EdgeInsets.only(left: 25)),
                            Text(
                              'Price of pack of cigarettes(\$):',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        NumberInputField(
                          controller: pricePerCigarettesController,
                          hintText: pricePerCigarettes.toString(),
                          obscureText: false,
                          isEnable: true,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Row(
                          children: [
                            Padding(padding: EdgeInsets.only(left: 25)),
                            Text(
                              'Number of cigarettes per pack:',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        NumberInputField(
                          controller: numCigarettesPerPackController,
                          hintText: numberOfCigarettesPerPack.toString(),
                          obscureText: false,
                          isEnable: true,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Watch motion tracking:',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              FlutterSwitch(
                                  value: motionTracking,
                                  showOnOff: true,
                                  activeColor:
                                      const Color.fromRGBO(115, 209, 60, 1),
                                  onToggle: (value) {
                                    setState(() {
                                      motionTracking = value;
                                    });
                                  })
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Daily tip:',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              FlutterSwitch(
                                  value: dailyTip,
                                  showOnOff: true,
                                  activeColor:
                                      const Color.fromRGBO(115, 209, 60, 1),
                                  onToggle: (value) {
                                    setState(() {
                                      dailyTip = value;
                                    });
                                  })
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        const Row(
                          children: [
                            Padding(padding: EdgeInsets.only(left: 25)),
                            Text(
                              'Password:',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                        const SizedBox(height: 10),
                        LoginTextField(
                          controller: passwordController,
                          hintText: "Password",
                          obscureText: true,
                          isEnable: true,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        const Row(
                          children: [
                            Padding(padding: EdgeInsets.only(left: 25)),
                            Text(
                              'New Password:',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                        const SizedBox(height: 10),
                        LoginTextField(
                          controller: newPasswordController,
                          hintText: "New Password",
                          obscureText: true,
                          isEnable: true,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              OutlinedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                style: ButtonStyle(
                                  minimumSize: const MaterialStatePropertyAll(
                                      Size(150, 50)),
                                  shape: MaterialStatePropertyAll(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                ),
                                child: const Text(
                                  'CANCEL',
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 16),
                                ),
                              ),
                              ElevatedButton(
                                  onPressed: () {
                                    if (pricePerCigarettesController
                                        .text.isNotEmpty) {
                                      pricePerCigarettes = int.parse(
                                          pricePerCigarettesController.text);
                                    }
                                    if (numCigarettesPerPackController
                                        .text.isNotEmpty) {
                                      numberOfCigarettesPerPack = int.parse(
                                          numCigarettesPerPackController.text);
                                    }
                                    BlocProvider.of<UserPreferencesCubit>(
                                            context)
                                        .saveUserPreference(
                                            pricePerCigarettes,
                                            numberOfCigarettesPerPack,
                                            motionTracking,
                                            dailyTip);
                                    if (username != null &&
                                        passwordController.text.isNotEmpty &&
                                        newPasswordController.text.isNotEmpty) {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return const Center(
                                            child: CircularProgressIndicator(),
                                          );
                                        },
                                      );
                                      BlocProvider.of<AmplifyAuthCubit>(context)
                                          .updatePassword(
                                              oldPassword:
                                                  passwordController.text,
                                              newPassword:
                                                  newPasswordController.text);
                                    } else {
                                      Navigator.pop(context);
                                    }
                                  },
                                  style: ButtonStyle(
                                    backgroundColor:
                                        const MaterialStatePropertyAll(
                                            Colors.orange),
                                    minimumSize: const MaterialStatePropertyAll(
                                        Size(150, 50)),
                                    shape: MaterialStatePropertyAll(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                  ),
                                  child: const Text(
                                    'SAVE',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ))
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 40,
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 25),
                          child: Text(
                            'If you have any questions about the Sense2Quit study, please contact the study team at (212)305-8198',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
