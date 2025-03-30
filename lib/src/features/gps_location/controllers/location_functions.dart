import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tablets/src/common/functions/debug_print.dart';
import 'package:tablets/src/common/functions/dialog_delete_confirmation.dart';
import 'package:tablets/src/common/functions/utils.dart';
import 'package:tablets/src/features/customers/model/customer.dart';
import 'package:tablets/src/features/gps_location/model/location.dart';
import 'package:tablets/src/features/gps_location/model/salespoint.dart';
import 'package:tablets/src/features/gps_location/repository/tasks_repository_provider.dart';
import 'package:tablets/src/features/transactions/repository/customer_repository_provider.dart';

Future<void> requestLocationPermission() async {
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }
}

Future<bool> isInsideCustomerZone(BuildContext context, WidgetRef ref, String customerDbRef) async {
  // const double targetLatitude = 37.4219983; // Example target latitude
  // const double targetLongitude = -122.084; // Example target longitude
  // const double targetLatitude = 36.3397525; // Example target latitude
  // const double targetLongitude = 43.2485551; // Example target longitude
  const double allowedDistance = 6; // meters allowed to be away form the gps point
  await requestLocationPermission();
  Position position = await Geolocator.getCurrentPosition();

  final customer = await getCustomer(ref, customerDbRef);

  final customerLocation = await getCustomerLocation(customer);

  if (customerLocation == null && context.mounted) {
    // if location is not register, return or register current location if salesman approves it
    final userConfiramtion = await showUserConfirmationDialog(
        context: context,
        messagePart1: '',
        messagePart2: 'موقع الزبون غير مسجل مسبقا, هل انت حاليا في موقع الزبون');
    if (userConfiramtion == null) {
      // user didn't confirm
      return false;
    }

    // add customer location to database
    customer.x = position.latitude;
    customer.y = position.longitude;
    final customerRepo = ref.read(customerRepositoryProvider);
    customerRepo.updateItem(customer);
  }

  double distance = Geolocator.distanceBetween(
      position.latitude, position.longitude, customerLocation!.x, customerLocation.y);

  if (distance > allowedDistance) {
    return false;
  }
  return true;
}

Future<Customer> getCustomer(WidgetRef ref, String customerDbRef) async {
  final customerRepo = ref.read(customerRepositoryProvider);
  final customers =
      await customerRepo.fetchItemListAsMaps(filterKey: 'dbRef', filterValue: customerDbRef);
  return Customer.fromMap(customers.first);
}

Future<Location?> getCustomerLocation(Customer customer) async {
  if (customer.x == null || customer.y == null) {
    return null;
  }
  return Location(x: customer.x!, y: customer.y!);
}

Future<bool> registerVisit(WidgetRef ref, String salesmanDbRef, String customerDbRef) async {
  final taskRepositoryProvider = ref.read(tasksRepositoryProvider);
  final salesPoints = await taskRepositoryProvider.fetchItemListAsMaps(
      filterKey: 'salesmanDbRef', filterValue: salesmanDbRef);
  if (salesPoints.isEmpty) {
    errorPrint('no matching customer found in tasks');
    return false;
  }
  final today = DateTime.now();
  final salesPointMap = salesPoints
      .where((item) =>
          item['customerDbRef'] == customerDbRef && isSameDay(item['date'].toDate(), today))
      .toList()
      .first;
  final salesPoint = SalesPoint.fromMap(salesPointMap);
  if (salesPoint.x == null || salesPoint.y == null) {
    final customer = await getCustomer(ref, customerDbRef);
    salesPoint.x = customer.x;
    salesPoint.y = customer.y;
  }
  salesPoint.isVisited = true;
  await taskRepositoryProvider.updateItem(salesPoint);
  return true;
}

// TODO to find a way to unfiy parts of register visit and resister transaction functions
Future<bool> registerTransaction(WidgetRef ref, String salesmanDbRef, String customerDbRef) async {
  await registerVisit(ref, salesmanDbRef, customerDbRef);
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
