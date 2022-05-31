// ignore_for_file: import_of_legacy_library_into_null_safe

import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DataSend extends StatefulWidget {
  const DataSend({Key? key}) : super(key: key);

  @override
  State<DataSend> createState() => _DataSendState();
}

class _DataSendState extends State<DataSend> {
  Geolocator geo = Geolocator();

  getCurrentLocation() async {
    Position position = await Geolocator().getCurrentPosition();
    var lat = position.latitude;
    var longt = position.longitude;
    GeoPoint point = GeoPoint(lat, longt);

    FirebaseFirestore.instance
        .collection('data')
        .add({'deviceID': 'why', 'geoLocation': point, 'rssi': 'rssi'});
  }

  @override
  Widget build(BuildContext context) {
    final sendButton = Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(30),
      color: Colors.redAccent,
      child: MaterialButton(
        padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        minWidth: MediaQuery.of(context).size.width,
        onPressed: () {},
        child: Text(
          "Send Location",
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
    // ignore: prefer_const_constructors
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        height: 300,
                      ),
                      sendButton,
                    ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
