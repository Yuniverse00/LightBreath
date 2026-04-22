import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 存储Key常量（移除固定的unpersistedDays/recordedDates，新增打卡记录前缀）
class QuitGoalKeys {
  static const quitType = "quit_goal_type";
  static const cycleDays = "quit_goal_cycle_days";
  static const currentDaily = "quit_goal_current_daily";
  static const reduceAmount = "quit_goal_reduce_amount";
  static const reduceCycle = "quit_goal_reduce_cycle";
  static const motivations = "quit_goal_motivations";
  static const startDate = "quit_goal_start_date";
  static const checkInCountPrefix = "check_in_count_"; // 打卡记录前缀（和打卡页一致）
}

class TargetSettingPage extends StatefulWidget {
  const TargetSettingPage({super.key});

  @override
  State<TargetSettingPage> createState() => _TargetSettingPageState();
}

class _TargetSettingPageState extends State<TargetSettingPage> {
  // 1. 戒烟类型选择
  String? _selectedQuitType;
  final List<String> _quitTypeOptions = ["完全戒烟", "逐步减量"];

  // 2. 固定戒烟周期
  int? _selectedCycleDays;
  final List<int> _cycleOptions = [15, 30, 45, 60];

  // 3. 逐步减量相关设置
  late TextEditingController _currentDailyController;
  late TextEditingController _reduceAmountController;
  String? _reduceCycle;
  final List<String> _reduceCycleOptions = ["每天", "每2天", "每3天","每5天","每10天"];

  // 4. 戒烟动力（多选）
  final List<String> _selectedMotivations = [];
  final List<String> _motivationOptions = [
    "健康原因",
    "节省开支",
    "家人健康",
    "工作需求",
    "提升形象",
  ];

  DateTime? _startDate;
  bool _hasSavedGoal = false;


  @override
  void initState() {
    super.initState();
    _currentDailyController = TextEditingController();
    _reduceAmountController = TextEditingController();
    _loadSavedGoal();
  }

  @override
  void dispose() {
    _currentDailyController.dispose();
    _reduceAmountController.dispose();
    super.dispose();
  }

  // 加载已保存的目标
  Future<void> _loadSavedGoal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? quitType = prefs.getString(QuitGoalKeys.quitType);
    if (quitType != null) _selectedQuitType = quitType;

    int? cycleDays = prefs.getInt(QuitGoalKeys.cycleDays);
    if (cycleDays != null) _selectedCycleDays = cycleDays;

    String? currentDaily = prefs.getString(QuitGoalKeys.currentDaily);
    if (currentDaily != null) _currentDailyController.text = currentDaily;

    String? reduceAmount = prefs.getString(QuitGoalKeys.reduceAmount);
    if (reduceAmount != null) _reduceAmountController.text = reduceAmount;

    String? reduceCycle = prefs.getString(QuitGoalKeys.reduceCycle);
    if (reduceCycle != null) _reduceCycle = reduceCycle;

    List<String>? motivations = prefs.getStringList(QuitGoalKeys.motivations);
    if (motivations != null) {
      _selectedMotivations.clear();
      _selectedMotivations.addAll(motivations);
    }

    String? startDateStr = prefs.getString(QuitGoalKeys.startDate);
    if (startDateStr != null) _startDate = DateTime.parse(startDateStr);

    // 判断是否有已保存的目标
    _hasSavedGoal = quitType != null && cycleDays != null && currentDaily != null && motivations != null;

    setState(() {});
  }

  // 计算已坚持天数
  int _calculatePersistedDays() {
    if (_startDate == null || _selectedCycleDays == null) return 0;

    final now = DateTime.now();
    final startDate = DateTime(_startDate!.year, _startDate!.month, _startDate!.day);
    final rawPersisted = now.difference(startDate).inDays;
    final safePersisted = rawPersisted >= 0 ? rawPersisted : 0;

    return safePersisted > _selectedCycleDays!
        ? _selectedCycleDays!
        : safePersisted;
  }

  // 计算剩余天数
  int? _calculateRemainingDays() {
    if (_selectedCycleDays == null) return null;
    final persisted = _calculatePersistedDays();
    final remaining = _selectedCycleDays! - persisted;
    return remaining > 0 ? remaining : 0;
  }

  bool _isGoalCompleted() {
    if (_selectedCycleDays == null) return false;
    return _calculatePersistedDays() >= _selectedCycleDays!;
  }

  // 计算单天目标（用于遍历打卡记录时判断是否达标）
  int _calculateDailyTargetForDate(DateTime date) {
    if (_selectedQuitType == "完全戒烟") return 0;
    if (_selectedQuitType != "逐步减量" || _startDate == null) return 0;

    int initialDaily = int.tryParse(_currentDailyController.text) ?? 0;
    int reduceAmount = int.tryParse(_reduceAmountController.text) ?? 0;
    if (initialDaily == 0 || reduceAmount == 0 || _reduceCycle == null) return 0;

    int cycleDays = _convertCycleToDays(_reduceCycle!);
    int daysSinceStart = date.difference(_startDate!).inDays;
    int totalReduce = (daysSinceStart ~/ cycleDays) * reduceAmount;
    int target = initialDaily - totalReduce;

    return target < 0 ? 0 : target;
  }

  // 自动计算未达标天数（读取每日打卡记录）
  Future<int> _calculateUnpersistedDays() async {
    if (_startDate == null) return 0;
    SharedPreferences prefs = await SharedPreferences.getInstance();

    int unpersisted = 0;
    int persistedDays = _calculatePersistedDays();

    for (int i = 0; i < persistedDays; i++) {
      DateTime date = _startDate!.add(Duration(days: i));
      String dateKey = DateFormat('yyyyMMdd').format(date);
      int actualSmoked = prefs.getInt("${QuitGoalKeys.checkInCountPrefix}$dateKey") ?? 0;
      int dailyTarget = _calculateDailyTargetForDate(date);
      if (actualSmoked > dailyTarget) {
        unpersisted++;
      }
    }
    return unpersisted;
  }

  // 计算实际达标率
  Future<double?> _calculateActualProgress() async {
    if (_selectedCycleDays == null || _startDate == null) return null;
    final persisted = _calculatePersistedDays();
    if (persisted == 0) return 0.0;
    final unpersisted = await _calculateUnpersistedDays();
    final actualPersisted = persisted - unpersisted;
    return (actualPersisted / _selectedCycleDays!).clamp(0.0, 1.0);
  }

  // 计算当日目标吸烟量
  int _calculateDailyTarget() {
    if (_selectedQuitType == "完全戒烟") return 0;
    if (_selectedQuitType != "逐步减量" || _startDate == null) return 0;

    int initialDaily = int.tryParse(_currentDailyController.text) ?? 0;
    int reduceAmount = int.tryParse(_reduceAmountController.text) ?? 0;
    if (initialDaily == 0 || reduceAmount == 0 || _reduceCycle == null) return 0;

    int cycleDays = _convertCycleToDays(_reduceCycle!);
    int daysSinceStart = _calculatePersistedDays();
    int totalReduce = (daysSinceStart ~/ cycleDays) * reduceAmount;
    int target = initialDaily - totalReduce;

    return target < 0 ? 0 : target;
  }

  // 转换减少周期为天数
  int _convertCycleToDays(String cycle) {
    switch (cycle) {
      case "每2天": return 2;
      case "每3天": return 3;
      case "每5天": return 5;
      case "每10天": return 10;
      default: return 1;
    }
  }

  // 跳转到目标设置页面（创建或修改）
  void _navigateToTargetSettings({bool isEdit = false}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TargetSettingsFormPage(
          isEdit: isEdit,
          quitType: _selectedQuitType,
          cycleDays: _selectedCycleDays,
          currentDaily: _currentDailyController.text,
          reduceAmount: _reduceAmountController.text,
          reduceCycle: _reduceCycle,
          selectedMotivations: _selectedMotivations,
          onSave: (quitType, cycleDays, currentDaily, reduceAmount, reduceCycle, motivations) async {
            // 保存目标
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setString(QuitGoalKeys.quitType, quitType);
            await prefs.setInt(QuitGoalKeys.cycleDays, cycleDays);
            await prefs.setString(QuitGoalKeys.currentDaily, currentDaily);

            if (quitType == "逐步减量") {
              await prefs.setString(QuitGoalKeys.reduceAmount, reduceAmount);
              await prefs.setString(QuitGoalKeys.reduceCycle, reduceCycle!);
            } else {
              await prefs.remove(QuitGoalKeys.reduceAmount);
              await prefs.remove(QuitGoalKeys.reduceCycle);
            }

            await prefs.setStringList(QuitGoalKeys.motivations, motivations);

            String? existingStartDate = prefs.getString(QuitGoalKeys.startDate);
            if (existingStartDate == null) {
              final now = DateTime.now();
              await prefs.setString(QuitGoalKeys.startDate, now.toIso8601String());
            }

            // 重新加载数据
            await _loadSavedGoal();

            // 显示成功提示
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isEdit ? "戒烟目标修改成功！" : "戒烟目标保存成功！"),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
        ),
      ),
    );
  }

  // 跳转到查看目标页面
  void _navigateToViewTarget() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TargetViewPage(
          quitType: _selectedQuitType,
          cycleDays: _selectedCycleDays,
          currentDaily: _currentDailyController.text,
          reduceAmount: _reduceAmountController.text,
          reduceCycle: _reduceCycle,
          selectedMotivations: _selectedMotivations,
          startDate: _startDate,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final persistedDays = _calculatePersistedDays();
    final remainingDays = _calculateRemainingDays();
    final dailyTarget = _calculateDailyTarget();
    final startDate = _startDate ?? DateTime.now();
    final targetDate = _selectedCycleDays != null
        ? startDate.add(Duration(days: _selectedCycleDays!))
        : null;
    final dateFormat = DateFormat("yyyy年MM月dd日");

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "戒烟目标设置",
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.green[600],
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Colors.green[50],
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 进度卡片
              FutureBuilder(
                future: Future.wait([_calculateUnpersistedDays(), _calculateActualProgress()]),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Colors.green));
                  }
                  final unpersistedDays = snapshot.data?[0] as int? ?? 0;
                  final actualProgress = snapshot.data?[1] as double? ?? 0.0;

                  return _buildProgressCard(
                      persistedDays,
                      unpersistedDays,
                      remainingDays,
                      actualProgress,
                      dailyTarget
                  );
                },
              ),
              const SizedBox(height: 30),

              if (!_hasSavedGoal) ...[
                Center(
                  child: ElevatedButton(
                    onPressed: () => _navigateToTargetSettings(isEdit: false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 16),
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 3,
                    ),
                    child: const Text(
                      "创建我的戒烟目标",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ] else ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        label: "查看",
                        icon: Icons.visibility,
                        color: Colors.blue,
                        onPressed: _navigateToViewTarget,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildActionButton(
                        label: "修改",
                        icon: Icons.edit,
                        color: Colors.orange,
                        onPressed: () => _navigateToTargetSettings(isEdit: true),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildActionButton(
                        label: "删除",
                        icon: Icons.delete,
                        color: Colors.red,
                        onPressed: _deleteGoal,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // 构建操作按钮
  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 2,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // 进度卡片
  Widget _buildProgressCard(
      int persistedDays,
      int unpersistedDays,
      int? remainingDays,
      double? actualProgress,
      int dailyTarget,
      ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green[500]!, Colors.green[300]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green[200]!,
            blurRadius: 5,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "当前戒烟目标进度",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),

          if (_selectedCycleDays == null)
            const Text("请先创建戒烟目标以查看进度", style: TextStyle(color: Colors.white, fontSize: 16))
          else ...[
            LinearProgressIndicator(
              value: actualProgress,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 15),

            Text("已达标：${persistedDays - unpersistedDays} 天",
                style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 16)),
            const SizedBox(height: 8),
            Text("未达标：$unpersistedDays 天",
                style: TextStyle(color: Colors.orange[100], fontSize: 16)),
            const SizedBox(height: 8),
            Text("剩余：${remainingDays ?? 0} 天",
                style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 16)),
            const SizedBox(height: 8),
            Text("今日目标：${dailyTarget == 0 ? "完全不吸烟" : "≤$dailyTarget 支"}",
                style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 16)),

            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                "实际达标率：${actualProgress != null ? (actualProgress * 100).toStringAsFixed(0) : "0"}%",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black12, blurRadius: 2)],
                ),
              ),
            ),

            if (_isGoalCompleted())
              const Padding(
                padding: EdgeInsets.only(top: 10),
                child: Text(
                  "🎉 当前戒烟周期已完成，进度数据已暂停",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

          ],
        ],
      ),
    );
  }

  // 删除目标
  Future<void> _deleteGoal() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("确认删除"),
        content: const Text("删除后所有戒烟目标数据将清空，进度将重置，是否确认？"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("取消")),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.remove(QuitGoalKeys.quitType);
                await prefs.remove(QuitGoalKeys.cycleDays);
                await prefs.remove(QuitGoalKeys.currentDaily);
                await prefs.remove(QuitGoalKeys.reduceAmount);
                await prefs.remove(QuitGoalKeys.reduceCycle);
                await prefs.remove(QuitGoalKeys.motivations);
                await prefs.remove(QuitGoalKeys.startDate);

                setState(() {
                  _selectedQuitType = null;
                  _selectedCycleDays = null;
                  _currentDailyController.clear();
                  _reduceAmountController.clear();
                  _reduceCycle = null;
                  _selectedMotivations.clear();
                  _startDate = null;
                  _hasSavedGoal = false;
                });

                _showSnackBar("戒烟目标已删除，进度已重置！", isSuccess: true);
              } catch (e) {
                _showSnackBar("删除失败：$e");
              }
            },
            child: const Text("确认删除", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

// 目标设置表单页面（用于创建和修改）
class TargetSettingsFormPage extends StatefulWidget {
  final bool isEdit;
  final String? quitType;
  final int? cycleDays;
  final String? currentDaily;
  final String? reduceAmount;
  final String? reduceCycle;
  final List<String> selectedMotivations;
  final Function(String, int, String, String, String?, List<String>) onSave;

  const TargetSettingsFormPage({
    super.key,
    required this.isEdit,
    this.quitType,
    this.cycleDays,
    this.currentDaily,
    this.reduceAmount,
    this.reduceCycle,
    required this.selectedMotivations,
    required this.onSave,
  });

  @override
  State<TargetSettingsFormPage> createState() => _TargetSettingsFormPageState();
}

class _TargetSettingsFormPageState extends State<TargetSettingsFormPage> {
  String? _selectedQuitType;
  final List<String> _quitTypeOptions = ["完全戒烟", "逐步减量"];

  int? _selectedCycleDays;
  final List<int> _cycleOptions = [15, 30, 45, 60];

  late TextEditingController _currentDailyController;
  late TextEditingController _reduceAmountController;
  String? _reduceCycle;
  final List<String> _reduceCycleOptions = ["每天", "每2天", "每3天","每5天","每10天"];

  final List<String> _selectedMotivations = [];
  final List<String> _motivationOptions = [
    "健康原因",
    "节省开支",
    "家人健康",
    "工作需求",
    "提升形象",
  ];

  @override
  void initState() {
    super.initState();
    _currentDailyController = TextEditingController();
    _reduceAmountController = TextEditingController();

    if (widget.isEdit) {
      _selectedQuitType = widget.quitType;
      _selectedCycleDays = widget.cycleDays;
      _currentDailyController.text = widget.currentDaily ?? '';
      _reduceAmountController.text = widget.reduceAmount ?? '';
      _reduceCycle = widget.reduceCycle;
      _selectedMotivations.addAll(widget.selectedMotivations);
    }
  }

  @override
  void dispose() {
    _currentDailyController.dispose();
    _reduceAmountController.dispose();
    super.dispose();
  }

  void _validateAndSave() {
    if (_selectedQuitType == null) {
      _showSnackBar("请选择戒烟类型");
      return;
    }
    if (_selectedCycleDays == null) {
      _showSnackBar("请选择戒烟周期");
      return;
    }
    if (_currentDailyController.text.isEmpty || int.parse(_currentDailyController.text) <= 0) {
      _showSnackBar("请输入有效的当前每日吸烟量");
      return;
    }
    if (_selectedQuitType == "逐步减量") {
      if (_reduceAmountController.text.isEmpty || int.parse(_reduceAmountController.text) <= 0) {
        _showSnackBar("请输入有效的每周期减少量");
        return;
      }
      if (_reduceCycle == null) {
        _showSnackBar("请选择减少周期");
        return;
      }
    }
    if (_selectedMotivations.isEmpty) {
      _showSnackBar("至少选择一个戒烟动力");
      return;
    }

    widget.onSave(
      _selectedQuitType!,
      _selectedCycleDays!,
      _currentDailyController.text.trim(),
      _reduceAmountController.text.trim(),
      _reduceCycle,
      List.from(_selectedMotivations),
    );

    Navigator.pop(context);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.isEdit ? "修改戒烟目标" : "创建戒烟目标",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.green[600],
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Colors.green[50],
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle(text: "一、选择戒烟类型"),
              const SizedBox(height: 15),
              _buildRadioGroup(
                options: _quitTypeOptions,
                selectedValue: _selectedQuitType,
                onChanged: (value) {
                  setState(() {
                    _selectedQuitType = value;
                  });
                },
              ),
              const SizedBox(height: 25),

              const SectionTitle(text: "二、选择戒烟周期"),
              const SizedBox(height: 15),
              _buildCycleRadioGroup(),
              const SizedBox(height: 25),

              if (_selectedQuitType != null) ...[
                SectionTitle(text: _selectedQuitType == "完全戒烟"
                    ? "三、完全戒烟设置"
                    : "三、逐步减量设置"),
                const SizedBox(height: 15),
                _buildNumberInput(
                  label: "当前每日吸烟量（支）",
                  controller: _currentDailyController,
                  hintText: "输入当前每天吸烟数",
                ),
                const SizedBox(height: 5),
                Text(
                  _selectedQuitType == "完全戒烟"
                      ? "（用于计算戒烟后的健康收益）"
                      : "（用于计算逐步减量的目标）",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 15),

                if (_selectedQuitType == "逐步减量") ...[
                  _buildNumberInput(
                    label: "每周期减少量（支）",
                    controller: _reduceAmountController,
                    hintText: "输入每周期减少的数量",
                  ),
                  const SizedBox(height: 15),
                  _buildDropdown(
                    label: "减少周期",
                    selectedValue: _reduceCycle,
                    options: _reduceCycleOptions,
                    onChanged: (value) {
                      setState(() {
                        _reduceCycle = value;
                      });
                    },
                  ),
                  const SizedBox(height: 25),
                ],
              ],

              const SectionTitle(text: "四、选择你的戒烟动力"),
              const SizedBox(height: 15),
              _buildMultiSelectTags(),
              const SizedBox(height: 40),

              Center(
                child: ElevatedButton(
                  onPressed: _validateAndSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 16),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 3,
                  ),
                  child: Text(
                    widget.isEdit ? "保存修改" : "创建目标",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCycleRadioGroup() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: _cycleOptions.map((days) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Radio<int>(
              value: days,
              groupValue: _selectedCycleDays,
              onChanged: (value) {
                setState(() {
                  _selectedCycleDays = value;
                });
              },
              activeColor: Colors.green[600],
            ),
            Text("$days 天"),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildRadioGroup({
    required List<String> options,
    required String? selectedValue,
    required Function(String?) onChanged,
  }) {
    return Column(
      children: options.map((option) {
        return RadioListTile<String>(
          title: Text(option),
          value: option,
          groupValue: selectedValue,
          onChanged: onChanged,
          activeColor: Colors.green[600],
          contentPadding: const EdgeInsets.symmetric(horizontal: 5),
          controlAffinity: ListTileControlAffinity.leading,
        );
      }).toList(),
    );
  }

  Widget _buildNumberInput({
    required String label,
    required TextEditingController controller,
    required String hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          ),
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? selectedValue,
    required List<String> options,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButton<String>(
            value: selectedValue,
            hint: Text("选择减少周期", style: TextStyle(color: Colors.grey.shade400)),
            isExpanded: true,
            underline: const SizedBox(),
            items: options.map((option) => DropdownMenuItem(value: option, child: Text(option))).toList(),
            onChanged: onChanged,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
        ),
      ],
    );
  }

  Widget _buildMultiSelectTags() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _motivationOptions.map((motivation) {
        final isSelected = _selectedMotivations.contains(motivation);
        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedMotivations.remove(motivation);
              } else {
                _selectedMotivations.add(motivation);
              }
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? Colors.green[600] : Colors.white,
              border: Border.all(color: isSelected ? Colors.green[600]! : Colors.grey[300]!),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Text(
              motivation,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontSize: 15,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// 目标查看页面
class TargetViewPage extends StatelessWidget {
  final String? quitType;
  final int? cycleDays;
  final String? currentDaily;
  final String? reduceAmount;
  final String? reduceCycle;
  final List<String> selectedMotivations;
  final DateTime? startDate;

  const TargetViewPage({
    super.key,
    required this.quitType,
    required this.cycleDays,
    required this.currentDaily,
    required this.reduceAmount,
    required this.reduceCycle,
    required this.selectedMotivations,
    required this.startDate,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat("yyyy年MM月dd日");
    final targetDate = startDate != null && cycleDays != null
        ? startDate!.add(Duration(days: cycleDays!))
        : null;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "我的戒烟目标",
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.green[600],
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Colors.green[50],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.1),
                      blurRadius: 5,
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "目标设置",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 20),

                    _buildInfoRow("戒烟类型", quitType ?? "未设置"),
                    _buildInfoRow("戒烟周期", cycleDays != null ? "$cycleDays 天" : "未设置"),

                    if (startDate != null) ...[
                      _buildInfoRow("开始日期", dateFormat.format(startDate!)),
                      if (targetDate != null)
                        _buildInfoRow("目标日期", dateFormat.format(targetDate)),
                    ],

                    const Divider(height: 30),

                    _buildInfoRow("当前每日吸烟量", currentDaily ?? "未设置"),

                    if (quitType == "逐步减量") ...[
                      _buildInfoRow("每周期减少量", reduceAmount ?? "未设置"),
                      _buildInfoRow("减少周期", reduceCycle ?? "未设置"),
                    ],

                    const Divider(height: 30),

                    const Text(
                      "戒烟动力",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: selectedMotivations.map((motivation) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.green[300]!),
                        ),
                        child: Text(
                          motivation,
                          style: TextStyle(color: Colors.green[800]),
                        ),
                      )).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String text;
  const SectionTitle({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
    );
  }
}