// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:sense2quit/Constants.dart';
import 'package:sense2quit/bloc/cubit/amplify_auth_cubit.dart';
import 'package:sense2quit/widgets/loginButton.dart';
import 'package:sense2quit/widgets/loginTextField.dart';
import 'package:sense2quit/main.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AmplifyAuthCubit, AmplifyAuthState>(
      listener: (context, state) {
        Navigator.of(context).pop();
        if (state.status == Constants.ERROR_MESSAGE_SET) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.errorMessage),
            backgroundColor: Colors.red,
          ));
        }

        if (state.status == Constants.LOGIN_SUCCEEDED) {
          Navigator.pushNamedAndRemoveUntil(
              context, '/home', (Route<dynamic> route) => false);
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
                        height: 200,
                        width: 200,
                      ),
                      const SizedBox(height: 30),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 25),
                            child: Text(
                              '账号：',
                              style: TextStyle(
                                  color: Colors.grey[700], fontSize: 18),
                            ),
                          ),
                        ],
                      ),
                      LoginTextField(
                        controller: usernameController,
                        hintText: '请输入用户名',
                        obscureText: false,
                        isEnable: true,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 25),
                            child: Text(
                              '密码：',
                              style: TextStyle(
                                  color: Colors.grey[700], fontSize: 18),
                            ),
                          ),
                        ],
                      ),
                      LoginTextField(
                        controller: passwordController,
                        hintText: '请输入密码',
                        obscureText: true,
                        isEnable: true,
                      ),
                      const SizedBox(height: 20),
                      LoginButton(
                        margin: 120,
                        text: '登录',
                        backgroundColor: Colors.green, // 绿色背景
                        textColor: Colors.white,       // 白色文字
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            },
                          );
                          BlocProvider.of<AmplifyAuthCubit>(context).signInUser(
                              usernameController.text.trim(),
                              passwordController.text.trim());
                        },
                      ),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/resetPassword');
                        },
                        child: const Text(
                          '忘记密码？',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 100),
                        child: Row(
                          children: [
                            Expanded(
                              child: Divider(
                                thickness: 0.5,
                                color: Colors.grey[700],
                              ),
                            ),
                            Padding(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                "或",
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                thickness: 0.5,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "还没有账号？",
                        style: TextStyle(color: Colors.grey[700], fontSize: 16),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/register');
                        },
                        child: const Text(
                          '注册新账号',
                          style: TextStyle(
                            color: Color(0xFF1A3E4C), // 墨蓝色
                            fontSize: 16,
                          ),
                        ),
                      ),
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