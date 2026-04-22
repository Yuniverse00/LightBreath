import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

import 'package:sense2quit/bloc/cubit/activity_cubit.dart';
import 'package:sense2quit/bloc/cubit/ble_connectivity_cubit.dart';
import 'package:sense2quit/models/SensorData.dart';
import 'package:sense2quit/widgets/loginTextField.dart';

class TaskSummary {
  final String startTimeMs;
  final String activityName;
  final int totalPoints;
  final int chunkCount;

  const TaskSummary({
    required this.startTimeMs,
    required this.activityName,
    required this.totalPoints,
    required this.chunkCount,
  });
}

class DataTransfer extends StatefulWidget {
  const DataTransfer({super.key});

  @override
  State<DataTransfer> createState() => _DataTransferState();
}

class _DataTransferState extends State<DataTransfer> {
  final activityNameController = TextEditingController();
  final durationController = TextEditingController();

  List<TaskSummary> _history = [];
  bool _loadingHistory = false;
  String? _historyError;
  bool _actionBusy = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      BlocProvider.of<BleConnectivityCubit>(context).scanAndConnect();
      _loadHistory();
    });
  }

  @override
  void dispose() {
    activityNameController.dispose();
    durationController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    if (!mounted) return;

    setState(() {
      _loadingHistory = true;
      _historyError = null;
    });

    try {
      final items = await Amplify.DataStore.query(SensorData.classType);

      final Map<String, List<SensorData>> grouped = {};
      for (final it in items) {
        (grouped[it.time] ??= []).add(it);
      }

      final List<TaskSummary> merged = [];

      for (final entry in grouped.entries) {
        final startTime = entry.key;
        final chunks = entry.value;

        chunks.sort((a, b) {
          final ta = int.tryParse(a.id) ?? 0;
          final tb = int.tryParse(b.id) ?? 0;
          return ta.compareTo(tb);
        });

        final activityName =
        chunks.isNotEmpty ? chunks.first.activity : "未命名任务";
        final totalPoints =
        chunks.fold<int>(0, (sum, e) => sum + e.data.length);
        final chunkCount = chunks.length;

        merged.add(
          TaskSummary(
            startTimeMs: startTime,
            activityName: activityName,
            totalPoints: totalPoints,
            chunkCount: chunkCount,
          ),
        );
      }

      merged.sort((a, b) {
        final ta = int.tryParse(a.startTimeMs) ?? 0;
        final tb = int.tryParse(b.startTimeMs) ?? 0;
        return tb.compareTo(ta);
      });

      if (!mounted) return;
      setState(() {
        _history = merged;
        _loadingHistory = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _historyError = e.toString();
        _loadingHistory = false;
      });
    }
  }

  String _formatMillis(String millisStr) {
    final ms = int.tryParse(millisStr);
    if (ms == null) return millisStr;
    final dt = DateTime.fromMillisecondsSinceEpoch(ms);
    return "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} "
        "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}";
  }

  String _escapeCsvField(String value) {
    final escaped = value.replaceAll('"', '""');
    return '"$escaped"';
  }

  Future<File> _exportTaskToCsv(TaskSummary task) async {
    final chunks = await Amplify.DataStore.query(
      SensorData.classType,
      where: SensorData.TIME.eq(task.startTimeMs),
    );

    chunks.sort((a, b) {
      final ta = int.tryParse(a.id) ?? 0;
      final tb = int.tryParse(b.id) ?? 0;
      return ta.compareTo(tb);
    });

    final StringBuffer buffer = StringBuffer();
    buffer.writeln('activity,startTimeMs,sensorType,value1,value2,value3,time');

    for (final chunk in chunks) {
      for (final point in chunk.data) {
        buffer.writeln(
          '${_escapeCsvField(chunk.activity)},'
              '${_escapeCsvField(chunk.time)},'
              '${_escapeCsvField(point.sensorType)},'
              '${point.value1},'
              '${point.value2},'
              '${point.value3},'
              '${_escapeCsvField(point.time)}',
        );
      }
    }

    final directory = await getTemporaryDirectory();
    final String safeActivityName =
    task.activityName.replaceAll(RegExp(r'[\\/:*?"<>| ]'), '_');
    final file = File(
      '${directory.path}/${safeActivityName}_${task.startTimeMs}.csv',
    );

    await file.writeAsString(buffer.toString(), flush: true);
    return file;
  }

  Future<void> _exportAndOpenTask(TaskSummary task) async {
    try {
      final file = await _exportTaskToCsv(task);
      final result = await OpenFilex.open(file.path);

      if (!mounted) return;

      if (result.type != ResultType.done) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('文件已导出，但打开失败：${result.message}'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('导出失败：$e')),
      );
    }
  }

  Future<void> _showTaskDetail(TaskSummary task) async {
    final timeStr = _formatMillis(task.startTimeMs);

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(task.activityName),
        content: Text(
          "开始时间：$timeStr\n采样点：${task.totalPoints}",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("关闭"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _exportAndOpenTask(task);
            },
            child: const Text("导出查看"),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteTaskByStartTime(String startTimeMs) async {
    try {
      final chunks = await Amplify.DataStore.query(
        SensorData.classType,
        where: SensorData.TIME.eq(startTimeMs),
      );

      for (final c in chunks) {
        await Amplify.DataStore.delete(c);
      }

      await _loadHistory();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("已删除该次任务的全部记录")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("删除失败：$e")),
      );
    }
  }

  Future<void> _confirmDeleteTask(TaskSummary task) async {
    final timeStr = _formatMillis(task.startTimeMs);
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("删除这次任务"),
        content: Text(
          "任务：${task.activityName}\n开始时间：$timeStr\n采样点：${task.totalPoints}\n\n确认删除吗",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("取消"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("删除"),
          ),
        ],
      ),
    );

    if (ok == true) {
      await _deleteTaskByStartTime(task.startTimeMs);
    }
  }

  Future<void> _handleStart() async {
    if (_actionBusy) return;

    setState(() {
      _actionBusy = true;
    });

    try {
      await BlocProvider.of<ActivityCubit>(context).startActivity(
        context,
        activityNameController.text.isNotEmpty
            ? activityNameController.text
            : "默认吸烟检测",
        int.tryParse(durationController.text) ?? 60,
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _actionBusy = false;
      });
    }
  }

  Future<void> _handleStop() async {
    if (_actionBusy) return;

    setState(() {
      _actionBusy = true;
    });

    try {
      await BlocProvider.of<ActivityCubit>(context).endActivity(context);
      await _loadHistory();
    } finally {
      if (!mounted) return;
      setState(() {
        _actionBusy = false;
      });
    }
  }

  Future<void> _handleReconnect() async {
    if (_actionBusy) return;

    setState(() {
      _actionBusy = true;
    });

    try {
      await BlocProvider.of<BleConnectivityCubit>(context).disconnect();
      if (!mounted) return;
      BlocProvider.of<BleConnectivityCubit>(context).scanAndConnect();
    } finally {
      if (!mounted) return;
      setState(() {
        _actionBusy = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          '手环检测',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.green[600],
        elevation: 2,
        actions: [
          IconButton(
            onPressed: _loadingHistory ? null : _loadHistory,
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: "刷新历史记录",
          )
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BlocBuilder<BleConnectivityCubit, BleState>(
                  builder: (context, state) {
                    final statusText = state.status ?? "unknown";

                    if (state.connected && state.deviceName != null) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "蓝牙已连接设备：${state.deviceName}",
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "当前状态：$statusText",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "蓝牙未连接设备",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "当前状态：$statusText",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        if (state.lastError != null &&
                            state.lastError!.trim().isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            "错误信息：${state.lastError}",
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),

                const SizedBox(height: 12),

                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton.icon(
                    onPressed: _actionBusy ? null : _handleReconnect,
                    icon: const Icon(Icons.bluetooth_searching),
                    label: const Text("重新连接手环"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green[700],
                      side: BorderSide(color: Colors.green.shade300),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: Text(
                        '检测任务名称：',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
                BlocBuilder<ActivityCubit, ActivityState>(
                  builder: (context, state) {
                    return LoginTextField(
                      controller: activityNameController,
                      hintText: state.activityInputEnabled == true
                          ? "输入检测任务名称（如：日常吸烟检测）"
                          : (state.activityName ?? "检测进行中"),
                      obscureText: false,
                      isEnable: state.activityInputEnabled ?? true,
                    );
                  },
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: Text(
                        '检测时长：',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
                BlocBuilder<ActivityCubit, ActivityState>(
                  builder: (context, state) {
                    return (state.durationInputEnabled ?? true)
                        ? LoginTextField(
                      controller: durationController,
                      keyboardType: TextInputType.number,
                      hintText: "输入检测时长（单位：秒）",
                      obscureText: false,
                      isEnable: state.durationInputEnabled ?? true,
                    )
                        : Text(
                      "${state.duration ?? 0} 秒",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    );
                  },
                ),

                const SizedBox(height: 18),

                BlocBuilder<ActivityCubit, ActivityState>(
                  builder: (context, state) {
                    String buttonText = "开始检测";

                    if (state.stop == false) {
                      buttonText = _actionBusy ? "处理中..." : "停止检测";
                      return ElevatedButton(
                        onPressed: _actionBusy ? null : _handleStop,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 12,
                          ),
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                        child: Text(
                          buttonText,
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }

                    buttonText = _actionBusy ? "处理中..." : "开始检测";
                    return ElevatedButton(
                      onPressed: _actionBusy ? null : _handleStart,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 12,
                        ),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                      child: Text(
                        buttonText,
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 12),

                Text(
                  "提示：开始检测前，请先确认手环已连接。结束检测后，请在弹窗中选择上传或丢弃，本页会在处理完成后自动刷新历史。",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 28),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "历史检测记录",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_loadingHistory)
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                  ],
                ),
                const SizedBox(height: 10),

                if (_historyError != null)
                  Text(
                    "读取历史失败：$_historyError",
                    style: const TextStyle(color: Colors.red),
                  ),

                if (!_loadingHistory && _history.isEmpty)
                  Text(
                    "暂无记录。开始并完成一次检测后，历史会显示在这里。",
                    style: TextStyle(color: Colors.grey.shade700),
                  ),

                ..._history.take(10).map((task) {
                  final timeStr = _formatMillis(task.startTimeMs);
                  return Card(
                    elevation: 1,
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      title: Text(
                        task.activityName,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        "开始时间：$timeStr\n采样点：${task.totalPoints}",
                      ),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        tooltip: "删除这次任务",
                        onPressed: () => _confirmDeleteTask(task),
                      ),
                      onTap: () => _showTaskDetail(task),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}