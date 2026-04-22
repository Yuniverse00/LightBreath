import 'package:bloc/bloc.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:sense2quit/bloc/cubit/amplify_data_store_cubit.dart';
import 'package:sense2quit/bloc/cubit/ble_connectivity_cubit.dart';

part 'activity_state.dart';

class ActivityCubit extends Cubit<ActivityState> {
  final AmplifyDataStoreCubit amplifyDataStoreCubit;
  final BleConnectivityCubit bleConnectivityCubit;

  ActivityCubit({
    required this.bleConnectivityCubit,
    required this.amplifyDataStoreCubit,
  }) : super(
    ActivityState(
      activityInputEnabled: true,
      durationInputEnabled: true,
      stop: true,
    ),
  );

  String? activityName;
  int? duration;
  bool stop = true;
  int last = 0;

  Timer? _countdownTimer;
  bool _isEnding = false;

  Future<void> startActivity(
      BuildContext context,
      String _activityName,
      int _duration,
      ) async {
    if (!bleConnectivityCubit.state.connected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('手环尚未连接，请先连接设备后再开始检测'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!stop) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('当前已有检测任务正在进行'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_duration <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请输入大于 0 的检测时长'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    _countdownTimer?.cancel();
    _isEnding = false;

    activityName = _activityName.trim().isNotEmpty ? _activityName.trim() : '默认吸烟检测';
    duration = _duration;
    stop = false;
    last = 0;

    amplifyDataStoreCubit.setStart(activityName!);

    emit(
      ActivityState(
        activityInputEnabled: false,
        durationInputEnabled: false,
        activityName: activityName,
        duration: duration,
        stop: stop,
      ),
    );

    try {
      await bleConnectivityCubit.startMeasurement();
    } catch (e) {
      stop = true;
      amplifyDataStoreCubit.clean();

      emit(
        ActivityState(
          activityInputEnabled: true,
          durationInputEnabled: true,
          activityName: activityName,
          duration: duration,
          stop: stop,
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('启动检测失败：$e'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    int temp = duration!;

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (stop || _isEnding) {
        timer.cancel();
        return;
      }

      if (temp > 0) {
        temp -= 1;
        last += 1;

        emit(
          ActivityState(
            activityInputEnabled: false,
            durationInputEnabled: false,
            activityName: activityName,
            duration: temp,
            stop: stop,
          ),
        );
      }

      if (temp <= 0) {
        timer.cancel();
        _finishActivity(context);
      }
    });
  }

  Future<void> endActivity(BuildContext context) async {
    await _finishActivity(context);
  }

  Future<void> _finishActivity(BuildContext context) async {
    if (stop || _isEnding) {
      return;
    }

    _isEnding = true;
    _countdownTimer?.cancel();
    _countdownTimer = null;

    try {
      await bleConnectivityCubit.stopMeasurement();
    } catch (e) {
      safePrint('stopMeasurement error: $e');
    }

    stop = true;

    emit(
      ActivityState(
        activityInputEnabled: true,
        durationInputEnabled: true,
        activityName: activityName,
        duration: duration,
        stop: stop,
      ),
    );

    await activityDialog(context);

    _isEnding = false;
  }

  Future<void> onPressedSave(BuildContext context) async {
    try {
      final bool isSuccess = await amplifyDataStoreCubit.saveData();

      if (!context.mounted) return;

      if (isSuccess) {
        amplifyDataStoreCubit.clean();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('数据已上传'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('数据上传失败'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
      safePrint('Error: $error');

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('上传出错：$error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> activityDialog(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          "检测任务 ${activityName ?? ''} 持续 $last 秒。您想上传还是丢弃收集的数据？",
        ),
        actions: [
          TextButton(
            onPressed: () {
              amplifyDataStoreCubit.clean();
              Navigator.of(dialogContext).pop();
            },
            child: const Text('丢弃'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await onPressedSave(context);
            },
            child: const Text('上传'),
          ),
        ],
      ),
    );
  }

  @override
  Future<void> close() {
    _countdownTimer?.cancel();
    return super.close();
  }
}