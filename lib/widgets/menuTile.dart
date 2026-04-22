import 'package:flutter/material.dart';

class MenuTile extends StatelessWidget {
  final String imagePath;
  final String pageName;
  final Function() onTap;

  const MenuTile({
    super.key,
    required this.imagePath,
    required this.pageName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      // 1. 调整外层边距：上下12，左右25，让模块之间间距更均匀
      child: Padding(
        padding: const EdgeInsets.fromLTRB(25, 12, 25, 12),
        child: Container(
          // 2. 增加内部边距：左右20，上下16，让内容不贴边
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16), // 3. 圆角调大一点，更柔和
            // 可选：增加轻微阴影，让模块更有层次感（不想加可以删掉这部分）
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // 图标保持原有尺寸，重点增加和文字的间距
              Image.asset(
                imagePath,
                fit: BoxFit.contain,
                height: 50,
                width: 50,
              ),
              const SizedBox(width: 20), // 4. 关键！图标和文字之间的间距
              Text(
                pageName,
                style: const TextStyle(
                  fontSize: 19, // 5. 文字略放大一点，更醒目
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}