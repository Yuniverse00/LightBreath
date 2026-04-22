import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sense2quit/bloc/cubit/amplify_auth_cubit.dart';

import '../constants.dart';
import '../widgets/loginButton.dart';
import '../widgets/loginTextField.dart';

class ConfirmReset extends StatefulWidget {
  const ConfirmReset({super.key});

  @override
  State<ConfirmReset> createState() => _ConfirmResetState();
}

class _ConfirmResetState extends State<ConfirmReset> {
  final confirmationCodeController = TextEditingController();
  final newPasswordController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AmplifyAuthCubit, AmplifyAuthState>(
      listener: (context, state) {
        // TODO: implement listener
        Navigator.of(context).pop();
        if (state.status == Constants.RESET_SUCCEEDED) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('密码重置成功'),
            backgroundColor: Colors.blue,
          ));
          sleep(const Duration(seconds: 3));
          Navigator.pushNamedAndRemoveUntil(
              context, '/login', (route) => false);
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
                        '轻息LightBreath 需要验证你的身份\n 我们已向你发送包含验证码的邮件',
                        style: TextStyle(color: Colors.grey[700], fontSize: 16),
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
                          obscureText: false, isEnable: true,),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 25,
                            ),
                            child: Text(
                              '设置新密码：',
                              style: TextStyle(
                                  color: Colors.grey[700], fontSize: 18),
                            ),
                          )
                        ],
                      ),
                      LoginTextField(
                          controller: newPasswordController,
                          hintText: '请输入新密码',
                          obscureText: true, isEnable: true,),
                      const SizedBox(
                        height: 50,
                      ),
                      LoginButton(
                          margin: 60,
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
                                .confirmResetPassword(
                                    newPassword:
                                        newPasswordController.text.trim(),
                                    confirmationCode:
                                        confirmationCodeController.text.trim());
                          },
                          text: '确认修改密码'),
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
