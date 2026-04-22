import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sense2quit/bloc/cubit/wear_os_connectivity_cubit.dart';

class ProfileKeys {
  static const username = "profile_username";
  static const age = "profile_age";
  static const gender = "profile_gender";
  static const smokingYears = "profile_smoking_years";
  static const dailyCigarettes = "profile_daily_cigarettes";
  static const smokingScene = "profile_smoking_scene";
  static const weight = "profile_weight";
  static const bloodPressure = "profile_blood_pressure";
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // 所有控制器改为可空类型，避免late未初始化报错
  TextEditingController? _usernameController;
  TextEditingController? _ageController;
  TextEditingController? _genderController;
  TextEditingController? _smokingYearsController;
  TextEditingController? _dailyCigarettesController;
  TextEditingController? _smokingSceneController;
  TextEditingController? _weightController;
  TextEditingController? _bloodPressureController;

  final String avatarPath = "lib/assets/avatar.png";

  @override
  void initState() {
    super.initState();
    _initDataFromLocalStorage();
  }

  @override
  void dispose() {
    // 可选链调用，避免空指针
    _usernameController?.dispose();
    _ageController?.dispose();
    _genderController?.dispose();
    _smokingYearsController?.dispose();
    _dailyCigarettesController?.dispose();
    _smokingSceneController?.dispose();
    _weightController?.dispose();
    _bloodPressureController?.dispose();
    super.dispose();
  }

  Future<void> _initDataFromLocalStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // 读取本地存储的所有数据
    String username = prefs.getString(ProfileKeys.username) ?? "戒烟达人";
    String age = prefs.getString(ProfileKeys.age) ?? "28岁";
    String gender = prefs.getString(ProfileKeys.gender) ?? "男";
    String smokingYears = prefs.getString(ProfileKeys.smokingYears) ?? "5年";
    String dailyCigarettes = prefs.getString(ProfileKeys.dailyCigarettes) ?? "10支/天";
    String smokingScene = prefs.getString(ProfileKeys.smokingScene) ?? "饭后、工作间隙";
    String weight = prefs.getString(ProfileKeys.weight) ?? "68kg";
    String bloodPressure = prefs.getString(ProfileKeys.bloodPressure) ?? "120/80 mmHg";

    // 初始化所有控制器
    setState(() {
      _usernameController = TextEditingController(text: username);
      _ageController = TextEditingController(text: age);
      _genderController = TextEditingController(text: gender);
      _smokingYearsController = TextEditingController(text: smokingYears);
      _dailyCigarettesController = TextEditingController(text: dailyCigarettes);
      _smokingSceneController = TextEditingController(text: smokingScene);
      _weightController = TextEditingController(text: weight);
      _bloodPressureController = TextEditingController(text: bloodPressure);
    });
  }

  Future<void> _saveField(String fieldName, String value, String storageKey) async {
    // 空值不保存
    if (value.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$fieldName 不能为空！')),
      );
      return;
    }

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(storageKey, value);

      debugPrint("✅ 保存 $fieldName 成功：$value");

      // 提示保存成功（防抖）
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$fieldName 修改成功！'),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      debugPrint("❌ 保存 $fieldName 失败：$e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$fieldName 保存失败：$e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // 获取用户名首字母，如果没有则返回空字符串
  String _getInitials() {
    if (_usernameController == null || _usernameController!.text.isEmpty) {
      return '';
    }
    String username = _usernameController!.text;
    // 取第一个字符，如果是中文则直接显示，英文取第一个字母大写
    String firstChar = username.isNotEmpty ? username[0] : '';
    // 如果是英文字母，转为大写
    if (firstChar.isNotEmpty && RegExp(r'[a-zA-Z]').hasMatch(firstChar)) {
      return firstChar.toUpperCase();
    }
    return firstChar;
  }

  // 根据用户名生成随机但稳定的背景颜色（灰色系）
  Color _getAvatarColor() {
    if (_usernameController == null || _usernameController!.text.isEmpty) {
      return Colors.grey[400]!; // 默认灰色
    }

    // 使用用户名生成一个稳定的哈希值
    String username = _usernameController!.text;
    int hash = username.codeUnits.fold(0, (prev, element) => prev + element);

    // 生成灰色系颜色（从300到600之间）
    List<Color> greyColors = [
      Colors.grey[300]!,
      Colors.grey[400]!,
      Colors.grey[500]!,
      Colors.grey[600]!,
      Colors.blueGrey[200]!,
      Colors.blueGrey[300]!,
      Colors.blueGrey[400]!,
    ];

    return greyColors[hash % greyColors.length];
  }

  Widget _editableText({
    required String title,
    required TextEditingController? controller,
    required String storageKey,
  }) {
    // 控制器未初始化时显示加载占位
    if (controller == null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(width: 180, child: Center(child: CircularProgressIndicator(strokeWidth: 1))),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(
            width: 180,
            child: TextField(
              controller: controller,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "请输入$title",
                hintStyle: TextStyle(color: Colors.grey.shade400),
              ),
              readOnly: false,
              onEditingComplete: () {
                String currentValue = controller.text.trim();
                _saveField(title, currentValue, storageKey);
                // 如果修改的是用户名，需要刷新头像
                if (storageKey == ProfileKeys.username) {
                  setState(() {});
                }
                FocusScope.of(context).unfocus();
              },
              onSubmitted: (value) {
                String currentValue = value.trim();
                _saveField(title, currentValue, storageKey);
                // 如果修改的是用户名，需要刷新头像
                if (storageKey == ProfileKeys.username) {
                  setState(() {});
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 控制器未初始化时显示加载页
    if (_usernameController == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "个人资料",
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.green[600],
        elevation: 2,
      ),
      backgroundColor: Colors.green[50],
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 头像+用户名区域
              Column(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.green[600]!, width: 3),
                    ),
                    child: ClipOval(
                      child: _buildAvatarContent(),
                    ),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: 200,
                    child: TextField(
                      controller: _usernameController!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        hintText: "请输入昵称",
                      ),
                      onEditingComplete: () {
                        String currentValue = _usernameController!.text.trim();
                        _saveField("用户名", currentValue, ProfileKeys.username);
                        FocusScope.of(context).unfocus();
                      },
                      onSubmitted: (value) {
                        String currentValue = value.trim();
                        _saveField("用户名", currentValue, ProfileKeys.username);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // 基本信息卡片
              InfoCard(
                title: "基本信息",
                children: [
                  _editableText(title: "年龄", controller: _ageController, storageKey: ProfileKeys.age),
                  _editableText(title: "性别", controller: _genderController, storageKey: ProfileKeys.gender),
                ],
              ),
              const SizedBox(height: 20),

              // 吸烟习惯卡片
              InfoCard(
                title: "吸烟习惯",
                children: [
                  _editableText(title: "吸烟年限", controller: _smokingYearsController, storageKey: ProfileKeys.smokingYears),
                  _editableText(title: "每日吸烟量", controller: _dailyCigarettesController, storageKey: ProfileKeys.dailyCigarettes),
                  _editableText(title: "常见吸烟场景", controller: _smokingSceneController, storageKey: ProfileKeys.smokingScene),
                ],
              ),
              const SizedBox(height: 20),

              // 健康数据卡片
              InfoCard(
                title: "健康数据",
                children: [
                  _editableText(title: "体重", controller: _weightController, storageKey: ProfileKeys.weight),
                  _editableText(title: "血压", controller: _bloodPressureController, storageKey: ProfileKeys.bloodPressure),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 构建头像内容（支持自定义头像和默认首字母头像）
  Widget _buildAvatarContent() {
    // 检查是否有自定义头像
    if (File(avatarPath).existsSync()) {
      return Image.asset(
        avatarPath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildDefaultAvatar();
        },
      );
    } else {
      return _buildDefaultAvatar();
    }
  }

  // 构建默认头像（灰色背景 + 白色首字母）
  Widget _buildDefaultAvatar() {
    String initials = _getInitials();
    Color bgColor = _getAvatarColor();

    return Container(
      color: bgColor,
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 48,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const InfoCard({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[200]!,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          Column(children: children),
        ],
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final String title;
  final String value;

  const InfoRow({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w400,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}