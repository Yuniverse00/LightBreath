import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sense2quit/bloc/cubit/amplify_auth_cubit.dart';
import 'package:sense2quit/constants.dart';
import '../widgets/menuTile.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
    getUsername();
  }

  Future<void> getUsername() async {
    try {
      final user = await Amplify.Auth.getCurrentUser();
      safePrint('当前用户：${user.username}');
    } catch (e) {
      safePrint('获取用户信息失败：$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AmplifyAuthCubit, AmplifyAuthState>(
      listener: (context, state) {
        Navigator.of(context).pop(); // 关闭加载弹窗
        if (state.status == Constants.ERROR_MESSAGE_SET) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 2),
            ),
          );
        }
        if (state.status == Constants.LOGOUT_SUCCEEDED) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('登出成功！'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 1),
            ),
          );
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/login',
                (Route<dynamic> route) => false,
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.green[50], // 改为浅绿色背景
          appBar: AppBar(
            centerTitle: true,
            title: const Text(
              '戒烟助手',
              style: TextStyle(
                color: Colors.black87, // 文字颜色改为深色以适应白色背景
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.white, // 顶部栏改为白色
            elevation: 2,
            iconTheme: const IconThemeData(color: Colors.black87), // 如果有返回按钮等图标，也改为深色
          ),
          // 登出悬浮按钮
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(right: 20, bottom: 20),
            child: Material(
              color: Colors.red[100],
              borderRadius: BorderRadius.circular(16),
              elevation: 3,
              child: InkWell(
                onTap: () {
                  // 显示加载弹窗
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const Center(
                      child: CircularProgressIndicator(color: Colors.red),
                    ),
                  );
                  BlocProvider.of<AmplifyAuthCubit>(context).signOutCurrentUser();
                },
                borderRadius: BorderRadius.circular(16),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                  child: Text(
                    '登出',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(), // 滚动回弹效果
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 15), // 上下留白
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 25, top: 10, bottom: 20),
                      child: Text(
                        '欢迎回来！继续你的戒烟之旅～',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),

                    // 1. 基础设置模块
                    const Padding(
                      padding: EdgeInsets.only(left: 25, bottom: 12),
                      child: Text(
                        "基础设置",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        MenuTile(
                          imagePath: 'lib/assets/profile.png', // 个人资料图标
                          pageName: "个人资料",
                          onTap: () => Navigator.pushNamed(context, "/profilePage"),
                        ),
                        MenuTile(
                          imagePath: 'lib/assets/target.png', // 戒烟目标图标
                          pageName: "戒烟目标设置",
                          onTap: () => Navigator.pushNamed(context, "/targetPage"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),

                    // 2. 数据与追踪模块
                    const Padding(
                      padding: EdgeInsets.only(left: 25, bottom: 12),
                      child: Text(
                        "数据与追踪",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        MenuTile(
                          imagePath: 'lib/assets/large_bw.png', // 手环连接图标
                          pageName: "手环检测",
                          onTap: () => Navigator.pushNamed(context, "/dataTransferPage"),
                        ),
                        MenuTile(
                          imagePath: 'lib/assets/check_in.png', // 日历式打卡图标
                          pageName: "戒烟打卡记录",
                          onTap: () => Navigator.pushNamed(context, "/checkInPage"),
                        ),
                        MenuTile(
                          imagePath: 'lib/assets/stats.png', // 数据统计图标
                          pageName: "健康数据统计",
                          onTap: () => Navigator.pushNamed(context, "/statsPage"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),

                    // 3. 互动与支持模块
                    const Padding(
                      padding: EdgeInsets.only(left: 25, bottom: 12),
                      child: Text(
                        "互动与支持",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        MenuTile(
                          imagePath: 'lib/assets/family.png', // 家庭支持图标
                          pageName: "家庭支持",
                          onTap: () => Navigator.pushNamed(context, "/familySupport"),
                        ),
                        MenuTile(
                          imagePath: 'lib/assets/community.png', // 社区互助图标
                          pageName: "吸烟社区互助",
                          onTap: () => Navigator.pushNamed(context, "/communityPage"),
                        ),
                        MenuTile(
                          imagePath: 'lib/assets/games.png', // 小游戏图标
                          pageName: "趣味小游戏",
                          onTap: () => Navigator.pushNamed(context, "/gamesPage"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),

                    // 4. 知识与教育模块
                    const Padding(
                      padding: EdgeInsets.only(left: 25, bottom: 12),
                      child: Text(
                        "知识与教育",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    MenuTile(
                      imagePath: 'lib/assets/icon_tips.png', // 复用原来的 Tips 图标
                      pageName: "戒烟知识库",
                      onTap: () => Navigator.pushNamed(context, "/tipsPage"), // 跳转原 TipsPage
                    ),
                    MenuTile(
                      imagePath: 'lib/assets/icon_faq.png', // FAQs 图标
                      pageName: "常见问题",
                      onTap: () => Navigator.pushNamed(context, "/faqsPage"),
                    ),
                    const SizedBox(height: 30), // 底部留白，避免被悬浮按钮遮挡
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}