import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../ui/styles/styles.dart';

final String containerTable = 'container_table';
final String terminalVehicleTable = 'terminal_vehicle_table';
final String newVehicleTable = 'new_vehicle_table';
final String bookedVehicleTable = 'booked_vehicle_table';
final String loadedVehicleTable = 'loaded_vehicle_table';
final String shippedVehicleTable = 'shipped_vehicle_table';
final String deliveredVehicleTable = 'delivered_vehicle_table';
final String releasedClientVehicleTable = 'released_client_vehicle_table';
final String vehicleImageTable = 'vehicle_image_table';
final String auctionTable = 'auction_table';

final String terminalVehicleImageTable = 'terminal_vehicle_image_table';
final String newVehicleImageTable = 'new_vehicle_image_table';
final String bookedVehicleImageTable = 'booked_vehicle_image_table';
final String loadedVehicleImageTable = 'loaded_vehicle_image_table';
final String shippedVehicleImageTable = 'shipped_vehicle_image_table';
final String deliveredVehicleImageTable = 'delivered_vehicle_image_table';
final String releasedVehicleImageTable = 'released_vehicle_image_table';

final String vehicleImageBaseUrl =
    'https://kgautoexport.s3.eu-north-1.amazonaws.com/';

showMightySnackBar({required String message, Color color = Colors.black}) {
  Get.showSnackbar(GetSnackBar(
    snackPosition: SnackPosition.BOTTOM,
    message: "${message}",
    duration: Duration(seconds: 5),
    leftBarIndicatorColor: color,
    margin: const EdgeInsets.all(kdPadding),
  ));
}

getLoading() {
  return Center(
    child: LoadingAnimationWidget.stretchedDots(
        color: kcPrimaryGradient, size: 30),
  );
}

getCircularLoading() {
  return Center(
    child: LoadingAnimationWidget.discreteCircle(
        color: kcPrimaryGradient,
        size: 50,
        secondRingColor: HexColor('#0375FF'),
        thirdRingColor: HexColor('#0375FF')),
  );
}

void printApiResponse(String text) {
  print('\x1B[33m$text\x1B[0m');
}
