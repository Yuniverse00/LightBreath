import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sense2quit/bloc/cubit/amplify_auth_cubit.dart';

import '../Constants.dart';
import '../widgets/loginButton.dart';
import '../widgets/loginTextField.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({super.key});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final usernameController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AmplifyAuthCubit, AmplifyAuthState>(
      listener: (context, state) {
        // 监听状态变化
        if (state.status == Constants.CONFIRMATION_REQUIRED) {
          Navigator.pushNamed(context, '/confirmReset');
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
                        '忘记密码？',
                        style: TextStyle(
                            color: Colors.red,
                            fontSize: 32,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        '我们将帮助你重置 轻息LightBreath 的登录密码！',
                        style: TextStyle(color: Colors.grey[700], fontSize: 16),
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                      Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 25),
                            child: Text(
                              '用户名：',
                              style: TextStyle(
                                  color: Colors.black87, fontSize: 18),
                            ),
                          )
                        ],
                      ),
                      LoginTextField(
                        controller: usernameController,
                        hintText: '请输入用户名',
                        obscureText: false,
                        isEnable: true,
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                      LoginButton(
                        margin: 100,
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
                              .resetPassword(usernameController.text.trim());
                        },
                        text: '重置密码',
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          '取消',
                          style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 20),
                        ),
                      )
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
