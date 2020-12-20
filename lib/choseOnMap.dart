
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:location/location.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

class ChoseOnMap extends StatefulWidget {

  // final FirebaseUser user;


  @override
  _ChoseOnMap createState() => _ChoseOnMap();
}
class _ChoseOnMap extends State<ChoseOnMap> {

  final String token = 'sk.eyJ1IjoibWF3YWlzIiwiYSI6ImNraGJvMnlhMTAwMG8yeG5vNXdlY2w2aTYifQ.maEiJc8WGc_0c1nZuWWeyQ';
  final String style = 'mapbox://styles/mapbox/streets-v11';

  LatLng result;
  Location location = new Location();

  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          child: const Text('OK',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          onPressed: () {

            double lat = result.latitude;
            double long = result.longitude;
            GeoPoint geopoint = new GeoPoint(lat, long);
            Navigator.pop(context, geopoint);
          },
        ),

        backgroundColor: Colors.grey[650],
        resizeToAvoidBottomPadding: true,
        body: SizedBox(
          child: MapboxMap(
            accessToken: token,
            styleString: style,
            initialCameraPosition: CameraPosition(
              zoom: 15.0,
              target: LatLng(14.508, 46.048),
            ),
            onMapCreated: (MapboxMapController controller) async {
               result = await _determinePosition();
               debugPrint(result.toString());

               location.onLocationChanged.listen((LocationData currentLocation) async {
                 if(!mounted) return;
                 setState(() async {
                   result = LatLng(currentLocation.latitude,currentLocation.longitude);
                   await controller.animateCamera(
                     CameraUpdate.newLatLng(LatLng(result.latitude,result.longitude)),
                   );

                   await controller.addCircle(
                     CircleOptions(
                       circleRadius: 13.0,
                       circleColor: '#4d94ff',
                       circleOpacity: 1,
                       geometry: LatLng(result.latitude,result.longitude),
                       draggable: true,
                     ),
                   );
                 });

               });





            },

          ),

        ));
  }

  _determinePosition() async {

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return null;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return null;
      }
    }

    _locationData = await location.getLocation();
    return LatLng(_locationData.latitude,_locationData.longitude);


  }
}




