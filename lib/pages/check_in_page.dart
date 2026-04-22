import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 导入持久化库
import 'package:sense2quit/constants.dart';

// 打卡数据存储Key（按日期存储，避免不同天数据覆盖）
class CheckInKeys {
  static const smokedToday = "check_in_smoked_";
  static const cigaretteCount = "check_in_count_";
}

class CheckInPage extends StatefulWidget {
  const CheckInPage({super.key});

  @override
  State<CheckInPage> createState() => _CheckInPageState();
}

class _CheckInPageState extends State<CheckInPage> {
  bool _smokedToday = false;
  int _cigaretteCount = 0;
  final String _currentDate = DateFormat('yyyy年MM月dd日').format(DateTime.now());
  final String _dateKey = DateFormat('yyyyMMdd').format(DateTime.now()); // 用于存储的日期key（纯数字）
  String? _checkInStatus;

  @override
  void initState() {
    super.initState();
    _loadSavedCheckIn(); // 页面初始化时加载已保存的打卡数据
  }

  // 从本地加载今日打卡数据
  Future<void> _loadSavedCheckIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // 读取今日是否吸烟（默认false）
    _smokedToday = prefs.getBool("${CheckInKeys.smokedToday}$_dateKey") ?? false;
    // 读取今日吸烟次数（默认0）
    _cigaretteCount = prefs.getInt("${CheckInKeys.cigaretteCount}$_dateKey") ?? 0;
    // 初始化打卡状态文本
    _updateCheckInStatus();
    // 更新UI
    setState(() {});
  }

  // 更新打卡状态文本
  void _updateCheckInStatus() {
    _checkInStatus = _smokedToday
        ? "已记录：今日吸烟 $_cigaretteCount 支"
        : "太棒了！今日成功戒烟✓";
  }

  void _saveCheckIn() async {
    try {
      // 保存数据到本地
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool("${CheckInKeys.smokedToday}$_dateKey", _smokedToday);
      await prefs.setInt("${CheckInKeys.cigaretteCount}$_dateKey", _cigaretteCount);

      // 更新状态文本
      setState(() {
        _updateCheckInStatus();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("打卡记录已保存"),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      safePrint("保存打卡记录失败: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("记录保存失败，请重试"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50], // 改为浅绿色背景
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          '戒烟打卡记录',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.green[600], // 改为绿色
        elevation: 2,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                        )
                      ]
                  ),
                  child: Text(
                    _currentDate,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              const Text(
                "今日是否吸烟？",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 15),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() {
                        _smokedToday = false;
                        _cigaretteCount = 0;
                        _updateCheckInStatus(); // 实时更新状态
                      }),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          color: _smokedToday ? Colors.white : Colors.green[50],
                          border: Border.all(
                            color: _smokedToday ? Colors.grey[300]! : Colors.green, // 改为绿色
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: _smokedToday ? Colors.grey[400] : Colors.green, // 改为绿色
                              size: 30,
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              "未吸烟",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() {
                        _smokedToday = true;
                        _updateCheckInStatus(); // 实时更新状态
                      }),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          color: _smokedToday ? Colors.red[50] : Colors.white,
                          border: Border.all(
                            color: _smokedToday ? Colors.red : Colors.grey[300]!,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.warning,
                              color: _smokedToday ? Colors.red : Colors.grey[400],
                              size: 30,
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              "已吸烟",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              if (_smokedToday) ...[
                const SizedBox(height: 40),
                const Text(
                  "吸烟支数",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 15),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () => setState(() {
                          if (_cigaretteCount > 0) _cigaretteCount--;
                          _updateCheckInStatus(); // 实时更新状态
                        }),
                        icon: Icon(Icons.remove, color: Colors.grey[600]),
                      ),

                      Text(
                        "$_cigaretteCount",
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),

                      IconButton(
                        onPressed: () => setState(() {
                          _cigaretteCount++;
                          _updateCheckInStatus(); // 实时更新状态
                        }),
                        icon: Icon(Icons.add, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 60),

              if (_checkInStatus != null)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Text(
                      _checkInStatus!,
                      style: TextStyle(
                        fontSize: 16,
                        color: _smokedToday ? Colors.orange[700] : Colors.green, // 成功状态改为绿色
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

              Center(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveCheckIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600], // 改为绿色
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                    ),
                    child: const Text(
                      "确认打卡",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}