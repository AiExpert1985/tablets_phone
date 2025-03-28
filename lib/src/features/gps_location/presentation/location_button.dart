import 'package:geolocator/geolocator.dart';

import 'package:flutter/material.dart';
import 'package:tablets/src/common/functions/debug_print.dart';
import 'package:tablets/src/common/functions/user_messages.dart';
import 'package:tablets/src/common/widgets/main_frame.dart';

Future<void> requestLocationPermission() async {
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }
}

class LocationButton extends StatelessWidget {
  final double targetLatitude = 36.3397525; // Example target latitude
  final double targetLongitude = 43.2485551; // Example target longitude
  final double allowedDistance = 6; // meters

  const LocationButton({super.key}); // Allowed distance in meters

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        await requestLocationPermission();
        Position position = await Geolocator.getCurrentPosition();

        tempPrint('Current Location: ${position.latitude}, ${position.longitude}');

        double distance = Geolocator.distanceBetween(
            position.latitude, position.longitude, targetLatitude, targetLongitude);

        if (distance > allowedDistance && context.mounted) {
          failureUserMessage(context, 'انت خارج نطاق الزبون');
        }
      },
      child: Container(
        width: 75,
        height: 80,
        decoration: BoxDecoration(
          border: Border.all(),
          borderRadius: const BorderRadius.all(Radius.circular(6)),
          gradient: itemColorGradient,
        ),
        padding: const EdgeInsets.all(12),
        child: const Center(
          child: Text(
            'زيارة',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
