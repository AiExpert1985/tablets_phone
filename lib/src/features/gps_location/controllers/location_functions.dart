import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tablets/src/common/functions/debug_print.dart';
import 'package:tablets/src/common/functions/utils.dart';
import 'package:tablets/src/features/gps_location/model/point.dart';
import 'package:tablets/src/features/gps_location/repository/tasks_repository_provider.dart';

Future<void> requestLocationPermission() async {
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }
}

Future<bool> isInsideCustomerZone() async {
  const double targetLatitude = 37.4219983; // Example target latitude
  const double targetLongitude = -122.084; // Example target longitude
  // const double targetLatitude = 36.3397525; // Example target latitude
  // const double targetLongitude = 43.2485551; // Example target longitude
  const double allowedDistance = 6; // meters
  await requestLocationPermission();
  Position position = await Geolocator.getCurrentPosition();

  tempPrint('Current Location: ${position.latitude}, ${position.longitude}');

  double distance = Geolocator.distanceBetween(
      position.latitude, position.longitude, targetLatitude, targetLongitude);

  if (distance > allowedDistance) {
    return false;
  }
  return true;
}

Future<bool> registerVisit(WidgetRef ref, String salesmanDbRef, String customerDbRef) async {
  final taskRepositoryProvider = ref.read(tasksRepositoryProvider);
  final tasks = await taskRepositoryProvider.fetchItemListAsMaps(
      filterKey: 'salesmanDbRef', filterValue: salesmanDbRef);
  if (tasks.isEmpty) {
    errorPrint('no matching customer found in tasks');
    return false;
  }
  final today = DateTime.now();
  final task = tasks
      .where((item) =>
          item['customerDbRef'] == customerDbRef && isSameDay(item['date'].toDate(), today))
      .toList()
      .first;
  task['isVisited'] = true;
  final point = SalesPoint.fromMap(task);
  await taskRepositoryProvider.updateItem(point);
  return true;
}

// TODO to find a way to unfiy parts of register visit and resister transaction functions
Future<bool> registerTransaction(WidgetRef ref, String salesmanDbRef, String customerDbRef) async {
  final taskRepositoryProvider = ref.read(tasksRepositoryProvider);
  final tasks = await taskRepositoryProvider.fetchItemListAsMaps(
      filterKey: 'salesmanDbRef', filterValue: salesmanDbRef);
  if (tasks.isEmpty) {
    errorPrint('no matching customer found in tasks');
    return false;
  }
  final today = DateTime.now();
  final task = tasks
      .where((item) =>
          item['customerDbRef'] == customerDbRef && isSameDay(item['date'].toDate(), today))
      .toList()
      .first;
  task['hasTransaction'] = true;
  final point = SalesPoint.fromMap(task);
  await taskRepositoryProvider.updateItem(point);
  return true;
}
