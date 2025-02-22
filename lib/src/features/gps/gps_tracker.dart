import 'dart:async';
import 'package:android_alarm_manager/android_alarm_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tablets/src/common/functions/debug_print.dart';

// track the location of mobile periodically every x minutes
Future<void> trackLoaction({int updateMinutes = 5}) async {
  await AndroidAlarmManager.initialize();
  // Schedule the periodic task
  await AndroidAlarmManager.periodic(
    Duration(minutes: updateMinutes), // Change this to your desired interval
    0, // Unique ID for the alarm
    sendLocationToFirebase,
  );
}

Future<void> sendLocationToFirebase(WidgetRef ref) async {
  Position position = await Geolocator.getCurrentPosition();
  Map<String, dynamic> locationMap = {
    'latitude': position.latitude,
    'longitude': position.longitude,
    'timestamp': DateTime.now().toIso8601String(),
  };
  addToFirebase(locationMap);
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
      tempPrint('Item added to live firestore successfully!');
      return;
    } catch (e) {
      errorPrint('Error adding item to live firestore: $e');
      return;
    }
  }
  // Device is offline
  final docRef = firestore.collection('locations').doc();
  docRef.set(locationMap).then((_) {
    tempPrint('Item added to firestore cache!');
  }).catchError((e) {
    errorPrint('Error adding item to firestore cache: $e');
  });
}
