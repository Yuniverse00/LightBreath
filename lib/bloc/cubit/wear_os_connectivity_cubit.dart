// ignore_for_file: unused_field

import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_wear_os_connectivity/flutter_wear_os_connectivity.dart';
import 'package:sense2quit/bloc/cubit/amplify_data_store_cubit.dart';

part 'wear_os_connectivity_state.dart';

class WearOsConnectivityCubit extends Cubit<WearOsConnectivityState> {
  final FlutterWearOsConnectivity _flutterWearOsConnectivity =
      FlutterWearOsConnectivity();
  List<WearOsDevice> _deviceList = [];
  WearOsDevice? _selectedDevice;
  DataItem? _dataItem;
  
  final List<StreamSubscription<WearOSMessage>> _messageSubscriptions = [];
  final List<StreamSubscription<List<DataEvent>>> _dataEventsSubscriptions = [];
  StreamSubscription<CapabilityInfo>? _connectedDeviceCapabilitySubscription;
  File? _imageFile;
  String? nodeId;
  final AmplifyDataStoreCubit amplifyDataStoreCubit;
  WearOsConnectivityCubit({required this.amplifyDataStoreCubit}) : super(WearOsConnectivityState());

  void configureWearOS() {
    _flutterWearOsConnectivity.configureWearableAPI().then((_) {
      _flutterWearOsConnectivity.getConnectedDevices().then((value) {
        _updateDeviceList(value.toList());
      });
      // _flutterWearOsConnectivity
      //     .findCapabilityByName("flutter_smart_watch_connected_nodes")
      //     .then((info) {
      //   _updateDeviceList(info!.associatedDevices.toList());
      // });
      _flutterWearOsConnectivity.getAllDataItems().then(inspect);
      _connectedDeviceCapabilitySubscription = _flutterWearOsConnectivity
          .capabilityChanged(
              capabilityPathURI: Uri(
                  scheme: "wear", // Default scheme for WearOS app
                  host: "*", // Accept all path
                  path:
                      "/flutter_smart_watch_connected_nodes" // Capability path
                  ))
          .listen((info) {
        if (info.associatedDevices.isEmpty) {
          _selectedDevice = null;
        }
        _updateDeviceList(info.associatedDevices.toList());
      });
      _listen();
      _listenData();
    });
  }

  void _updateDeviceList(List<WearOsDevice> devices) {
    _deviceList = devices;
  }

  void _listenData() {
    _flutterWearOsConnectivity.dataChanged(
        pathURI: Uri(scheme: "wear", host: "*", path: "/s2q-data-path"))
            .listen((dataEvents) {
      for (DataEvent event in dataEvents){
        // safePrint(
        //   event.dataItem.mapData
        // );
        amplifyDataStoreCubit.addDataPoint(event.dataItem);
        // dataFlow.smartWatchSensorUpdate(event.dataItem.mapData);
        // _saveRecordingData(event);
      }
    });
  }
 
  void _listen() {
    safePrint('listening on wear');
    _flutterWearOsConnectivity
        .messageReceived(
            pathURI: Uri(scheme: "wear", host: "*", path: "/s2q-message-path"))
        .listen((message) {
      final String data = String.fromCharCodes(message.data).toString();
      final int dataLength = data.length;
      safePrint(data);
      if (data == "Greeting from Sense2Quit-Wear"){
        nodeId = message.sourceNodeId;
        sendAcknowledgeMessage();

      }else if (dataLength > 19 && data.substring(0, 19) == "WearOS-acknowledge-") {
        emit(WearOsConnectivityState(wearDeviceName: data.substring(20)));
        nodeId = message.sourceNodeId;
      } else if (dataLength > 14 && data.substring(0,14) == "SensorService-") {
        if(data.substring(14) == "true") {
          // dataFlow.reset();
          emit(WearOsConnectivityState(wearDeviceName: state.wearDeviceName, sensorServiceStatus: "started"));
        }
        else{
          // dataFlow.saveData();
          emit(WearOsConnectivityState(wearDeviceName: state.wearDeviceName, sensorServiceStatus: "stopped"));
        }
      } else {
        emit(WearOsConnectivityState(
            wearDeviceName: state.wearDeviceName, currentMessage: message));
      }
    });
  }


  void sendAcknowledgeMessage() async {
    List<int> list = "Flutter-acknowledge".codeUnits;
    Uint8List bytes = Uint8List.fromList(list);
    _flutterWearOsConnectivity
          .sendMessage(bytes, deviceId: nodeId!, path: "/s2q-message-path")
          .then(print);
  }

  void sendHandShakeMessage() async {
    List<WearOsDevice> connectedDevices =
        await _flutterWearOsConnectivity.getConnectedDevices();
    List<int> list = 'Greeting from Sense2Quit'.codeUnits;
    Uint8List bytes = Uint8List.fromList(list);
    for (WearOsDevice device in connectedDevices) {
      _flutterWearOsConnectivity
          .sendMessage(bytes, deviceId: device.id, path: "/s2q-message-path")
          .then(print);
    }
  }

  // void getSensorStatus() async {
  //   List<int> list = "getSensorStatus".codeUnits;
  //   Uint8List bytes = Uint8List.fromList(list);
  //   _flutterWearOsConnectivity
  //         .sendMessage(bytes, deviceId: nodeId!, path: "/s2q-message-path")
  //         .then(print);
  // }
  
  void startMeasurement() {
        List<int> list = "Start Measurement".codeUnits;
    Uint8List bytes = Uint8List.fromList(list);
    // dataFlow.setActivityName(activityName);
    _flutterWearOsConnectivity
          .sendMessage(bytes, deviceId: nodeId!, path: "/s2q-message-path");
          safePrint('Starting measurement');
    
  }
  
  
    void stopMeasurement() {
        List<int> list = "Stop Measurement".codeUnits;
    Uint8List bytes = Uint8List.fromList(list);
    // dataFlow.setActivityName(activityName);
    _flutterWearOsConnectivity
          .sendMessage(bytes, deviceId: nodeId!, path: "/s2q-message-path");
          safePrint('Stoping measurement');
  }
  

}
