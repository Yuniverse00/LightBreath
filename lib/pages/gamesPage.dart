import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:sense2quit/widgets/playTile.dart';

class GamesPage extends StatefulWidget {
  const GamesPage({ Key? key }) : super(key: key);

  @override
  State<GamesPage> createState() => _GamesPageState();
}

class _GamesPageState extends State<GamesPage> {
  // 游戏玩法说明内容
  final String _gameInstructions = '''
基本规则：玩家上下左右划动控制吃豆人的移动方向，在迷宫中吃掉所有豆子，同时尽量避免与“烟鬼”正面相遇，利用迷宫的转角来躲避它们，并计划好路径以高效吃掉豆子，吃掉越多豆子可以获得越高的分数。
目标：在戒烟过程中玩吃豆人游戏，可以通过模拟“躲避烟鬼”的趣味互动，训练大脑在面对烟瘾冲动时快速转移注意力、做出“绕开诱惑”的决策，从而强化自我控制力。 
通过这些步骤，你可以开始享受吃豆人游戏的乐趣！''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50], // 改为浅绿色背景
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          '趣味小游戏',
          style: TextStyle(
            color: Colors.green, // 改为绿色
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.green[50], // 统一appbar背景色为浅绿色
        elevation: 0, // 去掉阴影
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40), // 顶部间距

                // 吃豆人logo放大居中
                Container(
                  width: 180, // 放大logo容器
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.green[100], // 浅绿色背景衬托
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(
                    'lib/assets/pacman.png',
                    fit: BoxFit.contain,
                  ),
                ),

                const SizedBox(height: 20),

                // 游戏名称放大
                const Text(
                  '吃豆人',
                  style: TextStyle(
                    fontSize: 32, // 放大字体
                    fontWeight: FontWeight.bold,
                    color: Colors.green, // 改为绿色
                  ),
                ),

                const SizedBox(height: 30),

                // 直接将instructions内容放在logo和名字下面
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 30),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    _gameInstructions,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),

                const SizedBox(height: 40),

                // 原来的play键放在instruction下面
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/pacman');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600], // 绿色按钮
                    padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 3,
                  ),
                  child: const Text(
                    '开始游戏',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 40), // 底部间距
              ],
            ),
          ),
        ),
      ),
    );
  }
}