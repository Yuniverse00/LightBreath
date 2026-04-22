part of 'wear_os_connectivity_cubit.dart';

class WearOsConnectivityState {
  WearOsDevice? selectedDevice;
  WearOSMessage? currentMessage;
  DataItem? dataItem;
  final List<StreamSubscription<WearOSMessage>> messageSubscriptions = [];
  final List<StreamSubscription<List<DataEvent>>> dataEventsSubscriptions = [];
  StreamSubscription<CapabilityInfo>? connectedDeviceCapabilitySubscription;
  File? imageFile;
  String? wearDeviceName;
  String? sensorServiceStatus;

  WearOsConnectivityState({this.wearDeviceName, this.selectedDevice, this.currentMessage, this.dataItem, this.sensorServiceStatus});

}
