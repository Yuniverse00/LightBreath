import 'dart:async';
import 'dart:io';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_wear_os_connectivity/flutter_wear_os_connectivity.dart';
import 'package:meta/meta.dart';

import 'package:sense2quit/models/DataPoint.dart';
import 'package:sense2quit/models/SensorData.dart';

part 'amplify_data_store_state.dart';

class AmplifyDataStoreCubit extends Cubit<AmplifyDataStoreState> {
  List<DataPoint> _buffer = <DataPoint>[];
  String? startTime;
  String activityName = ' ';
  String? username;

  bool _isSaving = false;

  AmplifyDataStoreCubit() : super(AmplifyDataStoreInitial());

  Future<void> getUsername() async {
    try {
      final user = await Amplify.Auth.getCurrentUser();
      username = user.username;
    } catch (e) {
      safePrint('getUsername failed: $e');
    }
  }

  void setStart(String name) {
    startTime = DateTime.now().millisecondsSinceEpoch.toString();
    activityName = name.trim().isNotEmpty ? name.trim() : '默认吸烟检测';
    _clearBuffer();
    safePrint('Data collection started: activity=$activityName, startTime=$startTime');
  }

  void clean() {
    _clearBuffer();
    startTime = null;
    activityName = ' ';
    safePrint('Data collection cleaned');
  }

  bool get isCollecting => startTime != null;

  int get bufferLength => _buffer.length;

  /// 原来的 WearOS DataItem 入口
  void addDataPoint(DataItem dataItem) {
    if (!isCollecting) {
      return;
    }

    String sensorType = 'OTHER';
    final Map<String, dynamic> data = dataItem.mapData;

    if (data['sensorType'] == 15) {
      sensorType = 'ACC';
    } else if (data['sensorType'] == 1) {
      sensorType = 'GYRO';
    }

    final values = data['values'];
    if (values == null || values is! List || values.length < 3) {
      safePrint('Invalid WearOS data values: $values');
      return;
    }

    final DataPoint dataPoint = DataPoint(
      sensorType: sensorType,
      value1: (values[0] as num).toDouble(),
      value2: (values[1] as num).toDouble(),
      value3: (values[2] as num).toDouble(),
      time: data['timestamp'].toString(),
    );

    _buffer.add(dataPoint);

    if (_buffer.length >= 100000) {
      _saveChunkSilently();
    }
  }

  /// BLE 入口
  void addBleDataPoint({
    required String sensorType,
    required double value1,
    required double value2,
    required double value3,
    String? timestamp,
  }) {
    if (!isCollecting) {
      return;
    }

    final DataPoint dataPoint = DataPoint(
      sensorType: sensorType,
      value1: value1,
      value2: value2,
      value3: value3,
      time: timestamp ?? DateTime.now().millisecondsSinceEpoch.toString(),
    );

    _buffer.add(dataPoint);

    if (_buffer.length >= 100000) {
      _saveChunkSilently();
    }
  }

  Future<void> _saveChunkSilently() async {
    if (_isSaving) {
      return;
    }

    if (!isCollecting) {
      return;
    }

    if (_buffer.isEmpty) {
      return;
    }

    if (username == null) {
      await getUsername();
    }

    if (username == null || startTime == null) {
      safePrint('Skip chunk save: username or startTime is null');
      return;
    }

    _isSaving = true;

    final List<DataPoint> temp = List<DataPoint>.from(_buffer);
    _clearBuffer();

    final SensorData sensorData = SensorData(
      username: username!,
      activity: activityName,
      time: startTime!,
      data: temp,
    );

    try {
      safePrint('Auto saving chunk, size=${temp.length}');
      await Amplify.DataStore.save(sensorData);
    } on DataStoreException catch (e) {
      safePrint('Auto chunk save failed: ${e.message}');
      _buffer.insertAll(0, temp);
    } catch (e) {
      safePrint('Auto chunk save failed: $e');
      _buffer.insertAll(0, temp);
    } finally {
      _isSaving = false;
    }
  }

  void _clearBuffer() {
    _buffer = <DataPoint>[];
  }

  Future<bool> saveData() async {
    if (_isSaving) {
      safePrint('saveData skipped: already saving');
      return false;
    }

    if (!isCollecting) {
      safePrint('saveData skipped: no active task');
      return false;
    }

    if (_buffer.isEmpty) {
      safePrint('saveData skipped: buffer is empty');
      return false;
    }

    if (username == null) {
      await getUsername();
    }

    if (username == null) {
      safePrint('saveData failed: username is null');
      return false;
    }

    if (startTime == null) {
      safePrint('saveData failed: startTime is null');
      return false;
    }

    _isSaving = true;

    final List<DataPoint> temp = List<DataPoint>.from(_buffer);
    _clearBuffer();

    final SensorData sensorData = SensorData(
      username: username!,
      activity: activityName,
      time: startTime!,
      data: temp,
    );

    try {
      safePrint('Manual save start');
      safePrint(sensorData);
      await Amplify.DataStore.save(sensorData);
      return true;
    } on DataStoreException catch (e) {
      safePrint('Something went wrong saving model: ${e.message}');
      _buffer.insertAll(0, temp);
      return false;
    } catch (e) {
      safePrint('Unexpected save error: $e');
      _buffer.insertAll(0, temp);
      return false;
    } finally {
      _isSaving = false;
    }
  }
}