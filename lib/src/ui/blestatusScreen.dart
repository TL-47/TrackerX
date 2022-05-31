import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:location/location.dart' as loc;
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart';

class BleStatusScreen extends StatefulWidget {
  const BleStatusScreen({required this.status, Key? key, })
      : super(key: key);

  final BleStatus status;
  

  @override
  State<BleStatusScreen> createState() => _BleStatusScreenState();
}

class _BleStatusScreenState extends State<BleStatusScreen> {
  

  String determineText(BleStatus status) {
    switch (status) {
      case BleStatus.unsupported:
        return "This device does not support Bluetooth";
      case BleStatus.unauthorized:
        return "Authorize the FlutterReactiveBle example app to use Bluetooth and location";
      case BleStatus.poweredOff:
        return "Bluetooth is powered off on your device turn it on";
      case BleStatus.locationServicesDisabled:
        return "Enable location services";
      case BleStatus.ready:
        return "Bluetooth is up and running";
      default:
        return "Waiting to fetch Bluetooth status $status";
    }
  }

  

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: Text(determineText(widget.status)),
        ),
      );
}
