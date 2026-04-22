import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sense2quit/bloc/cubit/amplify_auth_cubit.dart';
import 'package:sense2quit/constants.dart';

import 'package:sense2quit/widgets/loginButton.dart';
import 'package:sense2quit/widgets/loginTextField.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _retypeController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  bool passwordChecker(String password, String confirm) {
    if (password.length < 8 || confirm.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('密码长度至少为 8 位。'),
        backgroundColor: Colors.red,
      ));
      return false;
    } else if (password != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('两次输入的密码不一致。'),
        backgroundColor: Colors.red,
      ));
      return false;
    }
    return true;
  }

  bool vaildator() {
    String password = _passwordController.text.trim();
    String confirm = _retypeController.text.trim();
    String username = _usernameController.text.trim();
    String email = _emailController.text.trim();
    if (password.isEmpty ||
        confirm.isEmpty ||
        username.isEmpty ||
        email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('请填写所有必填项。'),
        backgroundColor: Colors.red,
      ));
      return false;
    }
    if (EmailValidator.validate(email) == false) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('请输入有效的邮箱地址。'),
        backgroundColor: Colors.red,
      ));
      return false;
    }
    if (passwordChecker(password, confirm) == false) {
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AmplifyAuthCubit, AmplifyAuthState>(
      listener: (context, state) {
        Navigator.of(context).pop();
        if (state.status == Constants.REGISTER_SUCCEEDED) {
          Navigator.pushNamed(context, '/confirm');
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
                            '注册账号',
                            style: TextStyle(
                                color: Color(0xFF1A3E4C), // 墨蓝色
                                fontSize: 32,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 25),
                                child: Text(
                                  '用户名：',
                                  style: TextStyle(
                                      color: Colors.grey[700], fontSize: 18),
                                ),
                              )
                            ],
                          ),
                          LoginTextField(
                            controller: _usernameController,
                            hintText: '请输入用户名',
                            obscureText: false,
                            isEnable: true,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 25),
                                child: Text(
                                  '邮箱地址：',
                                  style: TextStyle(
                                      color: Colors.grey[700], fontSize: 18),
                                ),
                              )
                            ],
                          ),
                          LoginTextField(
                            controller: _emailController,
                            hintText: '请输入邮箱地址',
                            obscureText: false,
                            isEnable: true,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 25),
                                child: Text(
                                  '密码：',
                                  style: TextStyle(
                                      color: Colors.grey[700], fontSize: 18),
                                ),
                              )
                            ],
                          ),
                          LoginTextField(
                            controller: _passwordController,
                            hintText: '请输入密码',
                            obscureText: true,
                            isEnable: true,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 25),
                                child: Text(
                                  '确认密码：',
                                  style: TextStyle(
                                      color: Colors.grey[700], fontSize: 18),
                                ),
                              )
                            ],
                          ),
                          LoginTextField(
                            controller: _retypeController,
                            hintText: '请再次输入密码',
                            obscureText: true,
                            isEnable: true,
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          LoginButton(
                            margin: 120,
                            onTap: () async {
                              bool res = vaildator();
                              if (res) {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  },
                                );
                                BlocProvider.of<AmplifyAuthCubit>(context)
                                    .signUpUser(
                                    username:
                                    _usernameController.text.trim(),
                                    password:
                                    _passwordController.text.trim(),
                                    email: _emailController.text.trim());
                              }
                            },
                            text: '注册',
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
                              child: const Text(
                                '取消',
                                style: TextStyle(color: Colors.red, fontSize: 16),
                              )),
                        ],
                      )),
                ),
              ),
            ));
      },
    );
  }
}