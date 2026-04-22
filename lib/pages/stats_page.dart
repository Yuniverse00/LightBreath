import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sense2quit/bloc/cubit/user_preferences_cubit.dart';
import 'package:sense2quit/constants.dart';

// 引入目标设置的Key常量（和TargetSettingPage保持一致）
class QuitGoalKeys {
  static const currentDaily = "quit_goal_current_daily";
  static const startDate = "quit_goal_start_date";
  static const quitType = "quit_goal_type";
}

// 实际打卡记录模型
class SmokingRecord {
  final DateTime date;
  final int cigarettesSmoked; // 当日实际吸烟数

  SmokingRecord({required this.date, required this.cigarettesSmoked});
}

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  // 实际打卡记录（从本地存储读取）
  List<SmokingRecord> _actualRecords = [];
  // 目标设置数据
  int _initialDailyCigarettes = 0; // 初始每日吸烟量（完全戒烟/逐步减量都有）
  DateTime? _quitStartDate; // 戒烟开始日期
  String? _quitType; // 戒烟类型（完全戒烟/逐步减量）

  // 单支尼古丁含量（行业标准）
  final double _nicotinePerStick = 1.2;

  @override
  void initState() {
    super.initState();
    _loadAllData(); // 初始化加载目标设置+打卡记录
  }

  // 加载目标设置+实际打卡记录
  Future<void> _loadAllData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // 加载目标设置数据
    _initialDailyCigarettes = int.tryParse(prefs.getString(QuitGoalKeys.currentDaily) ?? "0") ?? 0;
    String? startDateStr = prefs.getString(QuitGoalKeys.startDate);
    _quitStartDate = startDateStr != null ? DateTime.parse(startDateStr) : DateTime.now();
    _quitType = prefs.getString(QuitGoalKeys.quitType);

    // 加载实际打卡记录（从CheckInPage的存储读取）
    _actualRecords = await _loadSmokingRecordsFromLocal(prefs);

    setState(() {});
  }

  // 从本地存储读取打卡记录
  Future<List<SmokingRecord>> _loadSmokingRecordsFromLocal(SharedPreferences prefs) async {
    List<SmokingRecord> records = [];
    if (_quitStartDate == null) return records;

    // 计算戒烟天数，读取每一天的打卡记录
    int daysSinceQuit = DateTime.now().difference(_quitStartDate!).inDays;
    for (int i = 0; i <= daysSinceQuit; i++) {
      DateTime date = _quitStartDate!.add(Duration(days: i));
      String dateKey = DateFormat('yyyyMMdd').format(date);
      // 读取当日实际吸烟数（默认0）
      int smoked = prefs.getInt("check_in_count_$dateKey") ?? 0;
      records.add(SmokingRecord(date: date, cigarettesSmoked: smoked));
    }
    return records;
  }

  // 计算累计节省金额：(初始量 - 实际量)的每日总和 × 单支价格
  double _calculateTotalMoneySaved(double pricePerStick) {
    if (_actualRecords.isEmpty || _initialDailyCigarettes == 0) return 0;

    int totalReduced = _actualRecords.fold(0, (sum, record) {
      // 减少量不能为负（实际吸烟数超过初始量时按0算）
      int dailyReduced = (_initialDailyCigarettes - record.cigarettesSmoked).clamp(0, _initialDailyCigarettes);
      return sum + dailyReduced;
    });
    return totalReduced * pricePerStick;
  }

  // 计算累计减少尼古丁摄入
  double _calculateTotalNicotineReduced() {
    if (_actualRecords.isEmpty || _initialDailyCigarettes == 0) return 0;

    int totalReduced = _actualRecords.fold(0, (sum, record) {
      int dailyReduced = (_initialDailyCigarettes - record.cigarettesSmoked).clamp(0, _initialDailyCigarettes);
      return sum + dailyReduced;
    });
    return totalReduced * _nicotinePerStick;
  }

  // 肺功能改善预估（行业标准）
  String _calculateLungImprovementRate() {
    if (_quitStartDate == null) return "0%";
    int daysSinceQuit = DateTime.now().difference(_quitStartDate!).inDays;

    if (daysSinceQuit < 1) return "0%";
    if (daysSinceQuit < 7) return "10%"; // 1周：纤毛开始恢复
    if (daysSinceQuit < 30) return "20%"; // 1个月：呼吸更顺畅
    if (daysSinceQuit < 90) return "40%"; // 3个月：肺功能提升
    if (daysSinceQuit < 365) return "60%"; // 1年：肺功能显著改善
    return "80%"; // 1年以上：接近非吸烟者水平
  }

  // 近7天数据（用于趋势图）
  List<SmokingRecord> get _weeklyRecords =>
      _actualRecords.where((r) => r.date.isAfter(DateTime.now().subtract(const Duration(days: 7)))).toList();

  // 近30天数据（用于趋势图）
  List<SmokingRecord> get _monthlyRecords =>
      _actualRecords.length >= 30 ? _actualRecords.take(30).toList() : _actualRecords;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50], // 改为浅绿色背景
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          '健康数据统计',
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
              // 健康收益卡片
              const Text(
                "健康收益",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 15),
              BlocBuilder<UserPreferencesCubit, UserPreferencesState>(
                builder: (context, state) {
                  // 从用户偏好获取单价
                  final pricePerPack = state.pricePerCigarettes == 0 ? 20 : state.pricePerCigarettes;
                  final cigarettesPerPack = state.numberOfCigarettesPerPack == 0 ? 20 : state.numberOfCigarettesPerPack;
                  final pricePerStick = pricePerPack / cigarettesPerPack;

                  // 计算核心指标
                  final totalMoneySaved = _calculateTotalMoneySaved(pricePerStick);
                  final totalNicotineReduced = _calculateTotalNicotineReduced();
                  final lungImprovementRate = _calculateLungImprovementRate();

                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 1,
                    childAspectRatio: 3,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    children: [
                      // 累计节省金额 - 保持绿色
                      _buildStatCard(
                        title: "累计节省金额",
                        value: "¥${totalMoneySaved.toStringAsFixed(1)}",
                        icon: Icons.monetization_on,
                        color: Colors.green,
                        description: "基于每支${pricePerStick.toStringAsFixed(1)}元计算",
                      ),
                      // 减少尼古丁摄入 - 保持蓝色
                      _buildStatCard(
                        title: "减少尼古丁摄入",
                        value: "${totalNicotineReduced.toStringAsFixed(1)} mg",
                        icon: Icons.medical_services,
                        color: Colors.blue,
                        description: "每支香烟约含1.2mg尼古丁",
                      ),
                      // 肺功能改善预估 - 保持紫色
                      _buildStatCard(
                        title: "肺功能改善预估",
                        value: lungImprovementRate,
                        icon: Icons.air,
                        color: Colors.purple,
                        description: "戒烟越久，改善越显著",
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 30),

              // 近7天吸烟趋势图
              const Text(
                "近7天吸烟趋势",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 15),
              _weeklyRecords.isNotEmpty
                  ? Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                    )
                  ],
                ),
                height: 300,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: true, drawVerticalLine: false),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          // 每个点对应1天（单位为1）
                          interval: 1,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index >= _weeklyRecords.length) return const SizedBox();
                            // 显示星期几
                            return Text(
                              DateFormat.E().format(_weeklyRecords[index].date),
                              style: const TextStyle(fontSize: 12),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    minX: 0,
                    maxX: _weeklyRecords.length.toDouble() - 1,
                    minY: 0,
                    maxY: _initialDailyCigarettes.toDouble() + 5, // 适配初始量
                    lineBarsData: [
                      // 实际吸烟数曲线（限制最小值为0）
                      LineChartBarData(
                        spots: _weeklyRecords.asMap().entries.map((e) {
                          // 确保吸烟数≥0
                          double smoked = e.value.cigarettesSmoked.toDouble().clamp(0, double.infinity);
                          return FlSpot(e.key.toDouble(), smoked);
                        }).toList(),
                        isCurved: false,
                        color: Colors.red,
                        dotData: FlDotData(show: true),
                        belowBarData: BarAreaData(show: true, color: Colors.red.withOpacity(0.1)),
                      ),

                      // 目标基准线
                      LineChartBarData(
                        spots: _weeklyRecords.asMap().entries.map((e) {
                          double baseline =
                          _quitType == "完全戒烟" ? 0 : _initialDailyCigarettes.toDouble();
                          return FlSpot(e.key.toDouble(), baseline);
                        }).toList(),
                        isCurved: false,
                        color: Colors.green, // 改为绿色
                        dotData: FlDotData(show: false),
                        dashArray: const [5, 5], // 虚线样式
                      ),
                    ],
                  ),
                ),
              )
                  : const Text(
                "暂无近7天打卡数据",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),

              const SizedBox(height: 30),

              // 近30天吸烟趋势图
              const Text(
                "近30天吸烟趋势",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 15),

              // 添加月份标题
              if (_monthlyRecords.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 8, bottom: 5),
                  child: Text(
                    "${_monthlyRecords[0].date.month} 月", // 自动显示月份
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),

              _monthlyRecords.isNotEmpty
                  ? Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                    )
                  ],
                ),
                height: 300,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: true, drawVerticalLine: false),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 1, // 每天显示标签
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index >= _monthlyRecords.length) return const SizedBox();

                            // 只显示“日”
                            final day = _monthlyRecords[index].date.day;

                            return Text(
                              "$day",
                              style: const TextStyle(fontSize: 12),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    minX: 0,
                    maxX: _monthlyRecords.length.toDouble() - 1,
                    minY: 0,
                    maxY: _initialDailyCigarettes.toDouble() + 5,
                    lineBarsData: [
                      // 实际吸烟数曲线（限制最小值为0）
                      LineChartBarData(
                        spots: _monthlyRecords.asMap().entries.map((e) {
                          double smoked = e.value.cigarettesSmoked.toDouble().clamp(0, double.infinity);
                          return FlSpot(e.key.toDouble(), smoked);
                        }).toList(),
                        isCurved: false,
                        color: Colors.orange,
                        dotData: FlDotData(show: false),
                        belowBarData:
                        BarAreaData(show: true, color: Colors.orange.withOpacity(0.1)),
                      ),
                      // 初始目标基准线
                      LineChartBarData(
                        spots: _monthlyRecords.asMap().entries.map((e) {
                          double baseline =
                          _quitType == "完全戒烟" ? 0 : _initialDailyCigarettes.toDouble();
                          return FlSpot(e.key.toDouble(), baseline);
                        }).toList(),
                        isCurved: false,
                        color: Colors.green, // 改为绿色
                        dotData: FlDotData(show: false),
                        dashArray: const [5, 5],
                      ),
                    ],
                  ),
                ),
              )
                  : const Text(
                "暂无近30天打卡数据",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
          )
        ],
      ),
      child: Row(
        children: [
          // 图标区域
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 15),
          // 数据文本区域
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}