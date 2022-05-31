import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:trackerx1/src/ble/reactive_state.dart';
import 'package:meta/meta.dart';
import 'package:location/location.dart' as loc;

class BleScanner implements ReactiveState<BleScannerState> {
  BleScanner({
    required FlutterReactiveBle ble,
    required Function(String message) logMessage,
  })  : _ble = ble,
        _logMessage = logMessage;

  final FlutterReactiveBle _ble;
  final void Function(String message) _logMessage;
  final StreamController<BleScannerState> _stateStreamController =
      StreamController();

  final _devices = <DiscoveredDevice>[];
  StreamSubscription<loc.LocationData>? _locationSubscription;
  final loc.Location location = loc.Location();

  @override
  Stream<BleScannerState> get state => _stateStreamController.stream;

  void startScan(List<Uuid> serviceIds) {
    _logMessage('Start ble discovery');
    _devices.clear();
    _subscription?.cancel();
    _subscription =
        _ble.scanForDevices(withServices: serviceIds).listen((device) async {
      final knownDeviceIndex = _devices.indexWhere((d) => d.id == device.id);
      if (knownDeviceIndex >= 0) {
        _devices[knownDeviceIndex] = device;
      } else {
        _devices.add(device);
      }

      final snapShot = await FirebaseFirestore.instance
          .collection('tag1')
          .doc(device.id.toString())
          .get();

      if (snapShot.exists) {
        _locationSubscription =
            location.onLocationChanged.handleError((onError) {
          print(onError);
          _locationSubscription?.cancel();
        }).listen((loc.LocationData currentlocation) async {
          var lat = currentlocation.latitude;
          var longt = currentlocation.longitude;
          log('Tag detected!');

          GeoPoint point = GeoPoint(lat!, longt!);
          await FirebaseFirestore.instance
              .collection('tag1')
              .doc(device.id.toString())
              .set({
            'deviceID': device.id.toString(),
            'name': device.name,
            'geoLocation': point,
            'State': 'SUCCESS!',
            'rssi': device.rssi,
            'Last Detection': DateTime.now()
          }, SetOptions(merge: true));
        });
      } else if (snapShot == null || !snapShot.exists) {
        print('No tag detected');
        _locationSubscription?.cancel();
        _locationSubscription = null;
      }
      _pushState();
    }, onError: (Object e) => _logMessage('Device scan fails with error: $e'));
    _pushState();
  }

  void _pushState() {
    _stateStreamController.add(
      BleScannerState(
        discoveredDevices: _devices,
        scanIsInProgress: _subscription != null,
      ),
    );
  }

  Future<void> stopScan() async {
    _logMessage('Stop ble discovery');

    await _subscription?.cancel();
    _subscription = null;
    _devices.clear();

    _pushState();
  }

  Future<void> dispose() async {
    await _stateStreamController.close();
  }

  StreamSubscription? _subscription;
}

@immutable
class BleScannerState {
  const BleScannerState({
    required this.discoveredDevices,
    required this.scanIsInProgress,
  });

  final List<DiscoveredDevice> discoveredDevices;
  final bool scanIsInProgress;
}
