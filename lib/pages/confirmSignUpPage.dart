import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sense2quit/Constants.dart';
import 'package:sense2quit/bloc/cubit/amplify_auth_cubit.dart';

import 'package:sense2quit/widgets/loginButton.dart';
import 'package:sense2quit/widgets/loginTextField.dart';

class ConfirmSignUp extends StatefulWidget {
  const ConfirmSignUp({super.key});

  @override
  State<ConfirmSignUp> createState() => _ConfirmSignUpState();
}

class _ConfirmSignUpState extends State<ConfirmSignUp> {
  final confirmationCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AmplifyAuthCubit, AmplifyAuthState>(
      listener: (context, state) {
        Navigator.of(context).pop();
        if (state.status == Constants.CONFIRM_SUCCEEDED) {
          BlocProvider.of<AmplifyAuthCubit>(context).autoSignIn();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('正在登录中……'),
            backgroundColor: Colors.blue,
          ));
        }
        if (state.status == Constants.LOGIN_SUCCEEDED) {
          Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        }
        if (state.status == Constants.ERROR_MESSAGE_SET) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.errorMessage),
            backgroundColor: Colors.red,
          ));
        }
      },
      builder: (context, state) {
        return Container(
          decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("lib/assets/reg_background.png"),
                  fit: BoxFit.cover),
              color: Colors.white),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: SingleChildScrollView(
                child: Center(
                  child: Column(
                    children: [
                      const SizedBox(height: 50),
                      Image.asset(
                        'lib/assets/logo.png',
                        height: 120,
                        width: 120,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Text(
                        '账户验证',
                        style: TextStyle(
                            color: Color(0xFF1A3E4C), // 墨蓝色
                            fontSize: 32,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        '请输入通过邮箱收到的验证码。',
                        style: TextStyle(color: Colors.grey[700], fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 25,
                            ),
                            child: Text(
                              '验证码：',
                              style: TextStyle(
                                  color: Colors.grey[700], fontSize: 18),
                            ),
                          )
                        ],
                      ),
                      LoginTextField(
                        controller: confirmationCodeController,
                        hintText: '请输入验证码',
                        obscureText: false,
                        isEnable: true,
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                      LoginButton(
                        margin: 120,
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            },
                          );
                          BlocProvider.of<AmplifyAuthCubit>(context)
                              .confirmUser(
                              confirmationCode:
                              confirmationCodeController.text.trim());
                        },
                        text: '确认',
                        backgroundColor: Colors.green, // 绿色背景
                        textColor: Colors.white,       // 白色文字
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            '返回注册页',
                            style: TextStyle(
                                color: Colors.grey[700],
                                fontWeight: FontWeight.bold,
                                fontSize: 20),
                          ))
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}