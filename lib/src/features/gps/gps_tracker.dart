import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tablets/src/common/functions/debug_print.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> updateTasks() async {
  Position position = await Geolocator.getCurrentPosition();
  Map<String, dynamic> locationMap = {
    'latitude': position.latitude,
    'longitude': position.longitude,
    'timestamp': DateTime.now(),
  };
  tempPrint('Current location: $locationMap');
  // addToFirebase(locationMap);
}

void requestLocationPermission() async {
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }
  if (permission == LocationPermission.deniedForever) {
    // Handle the case when the user has denied the permission permanently
  }
}

void addToFirebase(Map<String, dynamic> locationMap) async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final connectivityResult = await Connectivity().checkConnectivity();
  if (connectivityResult.contains(ConnectivityResult.wifi) ||
      connectivityResult.contains(ConnectivityResult.ethernet) ||
      connectivityResult.contains(ConnectivityResult.vpn)) {
    // Device is connected to the internet
    try {
      await firestore.collection('locations').doc().set(locationMap);
      return;
    } catch (e) {
      errorPrint('Error adding item to live firestore: $e');
      return;
    }
  }
  // Device is offline
  final docRef = firestore.collection('locations').doc();
  docRef.set(locationMap).then((_) {}).catchError((e) {
    errorPrint('Error adding item to firestore cache: $e');
  });
}

Future<void> requestLocationPermissions() async {
  if (await Permission.location.isDenied) {
    await Permission.location.request();
  }
}
