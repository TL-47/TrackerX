import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:trackerx1/src/ble/ble_device_connector.dart';
import 'package:trackerx1/src/ui/device_detail/device_log_tab.dart';
import 'package:provider/provider.dart';
import 'package:location/location.dart' as loc;

import 'device_interaction_tab.dart';

class DeviceDetailScreen extends StatelessWidget {
  final DiscoveredDevice device;

  const DeviceDetailScreen({required this.device, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Consumer<BleDeviceConnector>(
        builder: (_, deviceConnector, __) => _DeviceDetail(
          device: device,
          disconnect: deviceConnector.disconnect,
        ),
      );
}

class _DeviceDetail extends StatefulWidget {
  const _DeviceDetail({
    required this.device,
    required this.disconnect,
    Key? key,
  }) : super(key: key);

  final DiscoveredDevice device;
  final void Function(String deviceId) disconnect;

  @override
  State<_DeviceDetail> createState() => _DeviceDetailState();
}

class _DeviceDetailState extends State<_DeviceDetail> {
  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () async {
          widget.disconnect(widget.device.id);

          return true;
        },
        child: DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              title: Text(widget.device.name),
              bottom: const TabBar(
                tabs: [
                  Tab(
                    icon: Icon(
                      Icons.bluetooth_connected,
                    ),
                  ),
                  Tab(
                    icon: Icon(
                      Icons.find_in_page_sharp,
                    ),
                  ),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                DeviceInteractionTab(
                  device: widget.device,
                ),
                const DeviceLogTab(),
              ],
            ),
          ),
        ),
      );

  // Future<void> _listenLocation() async {
  //   _locationSubscription = location.onLocationChanged.handleError((onError) {
  //     print(onError);
  //     _locationSubscription?.cancel();
  //     setState(() {
  //       _locationSubscription = null;
  //     });
  //   }).listen((loc.LocationData currentlocation) async {
  //     var lat = currentlocation.latitude;
  //     var longt = currentlocation.longitude;

  //     GeoPoint point = GeoPoint(lat!, longt!);
  //     FirebaseFirestore.instance.collection('tag1').doc('doc1').set({
  //       'deviceID': DiscoveredDevice$.id,
  //       'geoLocation': point,
  //       'isConnected': 'Connected',
  //       'rssi': DiscoveredDevice$.rssi,
  //     }, SetOptions(merge: true));
  //   });
  // }
}
