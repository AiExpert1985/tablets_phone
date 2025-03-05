import 'dart:async';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tablets/src/common/functions/debug_print.dart';

void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  // Request location permission
  await requestLocationPermission();

  // Runs every 10 seconds
  Timer.periodic(const Duration(minutes: 5), (timer) async {
    try {
      // Get the current position
      Position position = await Geolocator.getCurrentPosition();

      // Create a timestamp
      String timestamp = DateTime.now().toIso8601String();

      await Firebase.initializeApp();
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final docRef = firestore.collection('salesman_location').doc();

      // Upload location to Firestore
      await docRef.set({
        "latitude": position.latitude,
        "longitude": position.longitude,
        "timestamp": timestamp,
      });

      tempPrint("Location: ${position.latitude}, ${position.longitude}");
    } catch (e) {
      tempPrint("Error: $e");
    }
  });
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      isForegroundMode: true,
    ),
    iosConfiguration: IosConfiguration(),
  );
  service.startService();
}

Future<void> requestLocationPermission() async {
  LocationPermission permission = await Geolocator.checkPermission();

  // Handle denied permission
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }

  // Handle permanently denied permission
  if (permission == LocationPermission.deniedForever) {
    tempPrint("Location permission denied forever. Please enable it in settings.");
    return; // Exit the function or handle accordingly
  }
}
