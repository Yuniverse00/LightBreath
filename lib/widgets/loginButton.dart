import 'package:flutter/material.dart';

class LoginButton extends StatelessWidget {
  const LoginButton({
    super.key,
    required this.onTap,
    required this.text,
    required this.margin,
    this.backgroundColor = Colors.red, // 添加背景色参数，默认红色
    this.textColor = Colors.black,      // 添加文字颜色参数，默认黑色
  });

  final Function()? onTap;
  final String text;
  final double margin;
  final Color backgroundColor;  // 新增：背景色
  final Color textColor;        // 新增：文字颜色

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(25, 20, 25, 20),
        margin: EdgeInsets.symmetric(horizontal: margin),
        decoration: BoxDecoration(
          color: backgroundColor,  // 使用传入的背景色
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: textColor,  // 使用传入的文字颜色
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}