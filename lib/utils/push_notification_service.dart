import 'dart:convert';

import 'package:cargo/controllers/container_controller.dart';
import 'package:cargo/controllers/operator_controller.dart';
import 'package:cargo/controllers/vehicle_controller.dart';
import 'package:cargo/models/container_list_response.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

import '../models/vehicle_list_response.dart';
import '../ui/car/car_details_screen.dart';
import '../ui/container/container_details_screen.dart';

class PushNotificationService {
// It is assumed that all messages contain a data field with the key 'type'

  navigateToDetailsPage(RemoteMessage message) async {
    await navigateFromData(message.data);
  }

  Future<void> navigateFromData(Map<String, dynamic> data) async {
    try {
      var type = data['type'];
      if (type == 'add-vehicle' || type == 'status-changed') {
        var vehicleLookup = data['all_data'] ?? '';
        if (type == 'status-changed' && vehicleLookup is String) {
          try {
            final decodedVehicle = jsonDecode(vehicleLookup);
            if (decodedVehicle is Map && decodedVehicle['vin'] != null) {
              vehicleLookup = decodedVehicle['vin'].toString();
            }
          } catch (_) {
            // Keep the original value when the payload is already a VIN.
          }
        }
        VehicleController vehicleController = Get.find();
        vehicleController
            .getAllVehicleListFromNotification(vehicleLookup.toString())
            .then((value) {
          if (vehicleController.notificationVehicleList.isEmpty) return;
          VehicleList vehicle =
              vehicleController.notificationVehicleList.first;
          vehicleController.selectedPickupVehicle.value = vehicle;
          vehicleController.vehicleImageList.value =
              vehicle.vehicle!.vehicleImages!;
          vehicleController.getDestinationPortList();
          vehicleController.filterVehicleImageList();
          Get.to(() => CarDetailsScreen(
                vehicleList: vehicle,
              ));
        });
      } else if (type == "added-to-container") {
        Containers containers =
            notificationContainerResponseFromJson(data['all_data']);
        ContainerController containerController = Get.find();
        containerController
            .getAllContainerListFromNotification(containers.containerNo)
            .then((value) {
          Containers c = containerController.notificationContainerList.first;
          Get.to(() => ContainerDetailsScreen(
                con: c,
              ));
        });
      } else if (type == 'pickup-status-changed') {
        OperatorController operatorController = Get.find();
        operatorController.showPickupRequests();
      }
    } catch (err) {
      debugPrint(err.toString());
    }
  }

  Future<void> setupInteractedMessage() async {
    try {
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        navigateToDetailsPage(message);
      });
      enableIOSNotifications();
      await registerNotificationListeners();
    } catch (err) {
      debugPrint(err.toString());
    }
  }

  Future<void> registerNotificationListeners() async {
    try {
      final AndroidNotificationChannel channel = androidNotificationChannel();
      final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
          FlutterLocalNotificationsPlugin();
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/launcher_icon');
      const DarwinInitializationSettings iOSSettings =
          DarwinInitializationSettings(
        requestSoundPermission: false,
        requestBadgePermission: false,
        requestAlertPermission: false,
      );
      const InitializationSettings initSettings =
          InitializationSettings(android: androidSettings, iOS: iOSSettings);
      flutterLocalNotificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse details) {
          final payload = details.payload;
          if (payload == null || payload.isEmpty) return;
          final decoded = jsonDecode(payload);
          if (decoded is Map) {
            navigateFromData(Map<String, dynamic>.from(decoded));
          }
        },
      );
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
// onMessage is called when the app is in foreground and a notification is received
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        // homeController.getHomeData(
        //   withLoading: false,
        // );
        // if(message!.data['type']=='service_request'){
        //   ServiceProviderHomeController serviceProviderHomeController = Get.find();
        //   serviceProviderHomeController.notificationCount.value +=1;
        //   print(message.data['request_id']);
        //   serviceProviderHomeController.getAllServiceRequestWithoutLoading();
        //   serviceProviderHomeController.getServiceRequestById(message.data['request_id']);
        // }else if(message.data['type']=='invoice_request'){
        //   PersonalHomeController personalHomeController = Get.find();
        //   personalHomeController.notificationCount.value +=1;
        //   print(message.data['invoice_id']);
        //   // personalHomeController.getAllServiceRequestWithoutLoading();
        //   personalHomeController.getInvoiceById(message.data['invoice_id']);
        // }
        // var type = message!.data['type'];
        // if(type=='add-to-container'){
        //
        // }
        final RemoteNotification? notification = message.notification;
        final AndroidNotification? android = message.notification?.android;
// If `onMessage` is triggered with a notification, construct our own
        // local notification to show to users using the created channel.
        if (notification != null && android != null) {
          flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channelDescription: channel.description,
                icon: android.smallIcon,
              ),
            ),
            payload: jsonEncode(message.data),
          );
        }
      });
    } catch (err) {
      debugPrint(err.toString());
    }
  }

  Future<void> enableIOSNotifications() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true, // Required to display a heads up notification
      badge: true,
      sound: true,
    );
  }

  AndroidNotificationChannel androidNotificationChannel() =>
      const AndroidNotificationChannel(
        'high_importance_channel', // id
        'High Importance Notifications', // title
        description:
            'This channel is used for important notifications.', // description
        importance: Importance.max,
      );
}
