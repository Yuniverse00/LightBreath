import 'dart:async';
import 'dart:typed_data';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:sense2quit/bloc/cubit/amplify_data_store_cubit.dart';

class BleState {
  final String? deviceName;
  final String? deviceId;
  final bool connected;
  final String? status;
  final String? lastError;

  const BleState({
    this.deviceName,
    this.deviceId,
    this.connected = false,
    this.status,
    this.lastError,
  });

  BleState copyWith({
    String? deviceName,
    String? deviceId,
    bool? connected,
    String? status,
    String? lastError,
  }) {
    return BleState(
      deviceName: deviceName ?? this.deviceName,
      deviceId: deviceId ?? this.deviceId,
      connected: connected ?? this.connected,
      status: status ?? this.status,
      lastError: lastError,
    );
  }
}

class BleConnectivityCubit extends Cubit<BleState> {
  final AmplifyDataStoreCubit amplifyDataStoreCubit;

  BleConnectivityCubit({required this.amplifyDataStoreCubit})
      : super(const BleState(status: "idle"));

  final FlutterReactiveBle _ble = FlutterReactiveBle();

  StreamSubscription<DiscoveredDevice>? _scanSub;
  StreamSubscription<ConnectionStateUpdate>? _connSub;
  StreamSubscription<List<int>>? _accSub;
  StreamSubscription<List<int>>? _gyroSub;

  String? _deviceId;
  String? _deviceName;

  /// Services
  final Uuid unknownService =
  Uuid.parse("0000fda6-0000-1000-8000-00805f9b34fb");

  final Uuid sensorService =
  Uuid.parse("00001000-0000-1000-8000-00805f9b34fb");

  /// Writes
  final Uuid writeUnknown0100 =
  Uuid.parse("0000fda6-0100-4135-bc55-d47637b5332e");

  final Uuid writeUnknown0200 =
  Uuid.parse("0000fda6-0200-4135-bc55-d47637b5332e");

  final Uuid writeSensor1001 =
  Uuid.parse("00001001-0000-1000-8000-00805f9b34fb");

  /// Notifies
  final Uuid accNotify =
  Uuid.parse("00001002-0000-1000-8000-00805f9b34fb");

  final Uuid gyroNotify =
  Uuid.parse("00001003-0000-1000-8000-00805f9b34fb");

  Future<bool> _ensurePermissions() async {
    final loc = await Permission.locationWhenInUse.request();
    if (!loc.isGranted) {
      emit(state.copyWith(
        status: "permission denied",
        lastError: "location permission denied",
      ));
      return false;
    }
    return true;
  }

  List<double>? _tryParse3Float32LE(List<int> data) {
    if (data.length < 12) return null;
    final bd = ByteData.sublistView(Uint8List.fromList(data));
    final x = bd.getFloat32(0, Endian.little);
    final y = bd.getFloat32(4, Endian.little);
    final z = bd.getFloat32(8, Endian.little);
    return [x.toDouble(), y.toDouble(), z.toDouble()];
  }

  void scanAndConnect() async {
    final ok = await _ensurePermissions();
    if (!ok) return;

    await disconnect();

    emit(state.copyWith(status: "scanning", lastError: null));

    _scanSub = _ble
        .scanForDevices(
      withServices: [],
      scanMode: ScanMode.lowLatency,
    )
        .listen((d) {
      final name = d.name;
      if (name.contains("TicWatch") || name.contains("ticwatch")) {
        _deviceId = d.id;
        _deviceName = name.isNotEmpty ? name : "TicWatch";
        _scanSub?.cancel();
        _connect(_deviceId!);
      }
    }, onError: (e) {
      emit(state.copyWith(status: "scan error", lastError: e.toString()));
    });
  }

  void _connect(String deviceId) {
    emit(state.copyWith(status: "connecting", lastError: null));

    _connSub = _ble
        .connectToDevice(
      id: deviceId,
      connectionTimeout: const Duration(seconds: 12),
    )
        .listen((u) {
      final cs = u.connectionState;
      if (cs == DeviceConnectionState.connected) {
        emit(state.copyWith(
          connected: true,
          deviceId: deviceId,
          deviceName: _deviceName ?? "TicWatch",
          status: "connected",
          lastError: null,
        ));
        subscribeSensors();
      } else if (cs == DeviceConnectionState.disconnected) {
        emit(state.copyWith(
          connected: false,
          status: "disconnected",
        ));
      }
    }, onError: (e) {
      emit(state.copyWith(status: "connect error", lastError: e.toString()));
    });
  }

  void subscribeSensors() {
    if (_deviceId == null) return;

    final accChar = QualifiedCharacteristic(
      deviceId: _deviceId!,
      serviceId: sensorService,
      characteristicId: accNotify,
    );

    final gyroChar = QualifiedCharacteristic(
      deviceId: _deviceId!,
      serviceId: sensorService,
      characteristicId: gyroNotify,
    );

    _accSub?.cancel();
    _gyroSub?.cancel();

    _accSub = _ble.subscribeToCharacteristic(accChar).listen((data) {
      final v = _tryParse3Float32LE(data);

      if (v != null) {
        amplifyDataStoreCubit.addBleDataPoint(
          sensorType: "ACC",
          value1: v[0],
          value2: v[1],
          value3: v[2],
          timestamp: DateTime.now().millisecondsSinceEpoch.toString(),
        );
      } else {
        safePrint("ACC raw len=${data.length} data=$data");
      }
    }, onError: (e) {
      safePrint("BLE ACC subscribe error: $e");
      emit(state.copyWith(lastError: "acc subscribe error: $e"));
    });

    _gyroSub = _ble.subscribeToCharacteristic(gyroChar).listen((data) {
      final v = _tryParse3Float32LE(data);

      if (v != null) {
        amplifyDataStoreCubit.addBleDataPoint(
          sensorType: "GYRO",
          value1: v[0],
          value2: v[1],
          value3: v[2],
          timestamp: DateTime.now().millisecondsSinceEpoch.toString(),
        );
      } else {
        safePrint("GYRO raw len=${data.length} data=$data");
      }
    }, onError: (e) {
      safePrint("BLE GYRO subscribe error: $e");
      emit(state.copyWith(lastError: "gyro subscribe error: $e"));
    });

    emit(state.copyWith(status: "subscribed"));
  }

  Future<void> startMeasurement() async {
    await _writeCommand("Start Measurement");
  }

  Future<void> stopMeasurement() async {
    await _writeCommand("Stop Measurement");
  }

  Future<void> _writeCommand(String cmd) async {
    if (_deviceId == null || !state.connected) {
      emit(state.copyWith(lastError: "device not connected"));
      return;
    }

    final bytes = Uint8List.fromList(cmd.codeUnits);

    final targets = <QualifiedCharacteristic>[
      QualifiedCharacteristic(
        deviceId: _deviceId!,
        serviceId: unknownService,
        characteristicId: writeUnknown0100,
      ),
      QualifiedCharacteristic(
        deviceId: _deviceId!,
        serviceId: unknownService,
        characteristicId: writeUnknown0200,
      ),
      QualifiedCharacteristic(
        deviceId: _deviceId!,
        serviceId: sensorService,
        characteristicId: writeSensor1001,
      ),
    ];

    emit(state.copyWith(status: "writing $cmd", lastError: null));

    for (final t in targets) {
      try {
        await _ble.writeCharacteristicWithResponse(t, value: bytes);
        safePrint("BLE wrote $cmd to ${t.characteristicId}");
      } catch (e) {
        safePrint("BLE write failed $cmd to ${t.characteristicId}: $e");
      }
    }

    emit(state.copyWith(status: "write done"));
  }

  Future<void> disconnect() async {
    await _scanSub?.cancel();
    await _connSub?.cancel();
    await _accSub?.cancel();
    await _gyroSub?.cancel();

    _scanSub = null;
    _connSub = null;
    _accSub = null;
    _gyroSub = null;

    emit(state.copyWith(
      connected: false,
      status: "idle",
    ));
  }

  @override
  Future<void> close() async {
    await disconnect();
    return super.close();
  }
}