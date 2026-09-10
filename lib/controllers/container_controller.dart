import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cargo/controllers/vehicle_controller.dart';
import 'package:cargo/models/container_list_response.dart';
import 'package:cargo/models/destination_port_response.dart';
import 'package:cargo/models/vehicle_email_history.dart';
import 'package:cargo/ui/container/track_container.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../utils/api_helper.dart';
import '../utils/global_helpers.dart';
import 'auth_controller.dart';

class ContainerController extends GetxController {
  RxBool kIsLoading = false.obs;
  RxInt indexNo = 1.obs;
  Rx<ContainerListResponse?> containerListResponse =
      Rx<ContainerListResponse?>(null);
  RxList<Containers> containerList = RxList();
  RxList<Containers> filterContainerList = RxList();

  Rx<Containers?> selectedContainer = Rx<Containers?>(null);
  RxList<VehicleEmailHistory> emailHistoryList = RxList();
  TextEditingController emailController = TextEditingController();
  RxBool sendingEmail = false.obs;
  RxMap<String, dynamic> containerFilterOptions = <String, dynamic>{}.obs;
  Rxn<dynamic> selectedFilterPort = Rxn<dynamic>();
  Rxn<dynamic> selectedFilterStatus = Rxn<dynamic>();
  Rxn<dynamic> selectedFilterPayment = Rxn<dynamic>();
  final VehicleController _vehicleController = Get.find();

  void clearAccountData() {
    indexNo.value = 1;
    kIsLoading(false);
    containerListResponse.value = null;
    containerList.clear();
    filterContainerList.clear();
    selectedContainer.value = null;
    emailHistoryList.clear();
    emailController.clear();
    sendingEmail(false);
    containerFilterOptions.clear();
    selectedFilterPort.value = null;
    selectedFilterStatus.value = null;
    selectedFilterPayment.value = null;
    serverContainerList.clear();
    notificationContainerList.clear();
    searchOnStoppedTyping.value?.cancel();
    searchStringController.clear();
  }

  trackContainer(String lineName, String containerNo) async {
    try {
      DestinationPort shippingLine = _vehicleController.shippingLineList
          .firstWhere((element) => element.name == lineName);
      if (shippingLine.scacCode == 'MAEU') {
        Get.to(TrackContainerScreen(
            url: 'https://www.maersk.com/tracking/$containerNo'));
      } else if (shippingLine.scacCode == 'HAPAG-LLOYD') {
        Get.to(TrackContainerScreen(
            url:
                'https://www.hapag-lloyd.com/en/online-business/track/track-by-container-solution.html?container=$containerNo'));
      } else {
        Get.to(TrackContainerScreen(
            url:
                'https://www.searates.com/container/tracking/?container=$containerNo&sealine=AUTO'));
      }
    } catch (err) {
      debugPrint(err.toString());
    }
  }

  refreshContainer(RefreshController refreshController) async {
    await getContainerList(isRefresh: true);
    if (kIsLoading.isTrue) {
      refreshController.requestLoading();
    } else {
      refreshController.refreshCompleted();
    }
  }

  loadMoreContainer(RefreshController refreshController) async {
    try {
      await getContainerList(
        isRefresh: false,
      );
      if (kIsLoading.isTrue) {
        refreshController.requestLoading();
      } else {
        refreshController.loadComplete();
      }
    } catch (err) {
      debugPrint(err.toString());
    }
  }

  Future<void> getContainerList({bool? isRefresh}) async {
    try {
      if (isRefresh!) {
        indexNo.value = 1;
        kIsLoading(true);
      }

      var moduleRes =
          await ApiHelper().getDataAuthenticated(_containerListEndpoint());

      ContainerListResponse vlr =
          containerListResponseFromJson(jsonEncode(moduleRes));

      if (isRefresh) {
        containerList.clear();
        filterContainerList.clear();
        containerList.addAll(vlr.containerList);
        filterContainerList.addAll(vlr.containerList);
      } else {
        containerList.addAll(vlr.containerList);
        filterContainerList.addAll(vlr.containerList);
        containerList.refresh();
        filterContainerList.refresh();
      }

      indexNo.value += 1;
      indexNo.refresh();
    } catch (error) {
      debugPrint(error.toString());
    } finally {
      kIsLoading(false);
    }
  }

  String _filterOptionValue(dynamic option) {
    if (option is Map) {
      return (option['id'] ?? option['value'] ?? '').toString();
    }
    return option?.toString() ?? '';
  }

  String _containerListEndpoint() {
    final params = <String, String>{
      'PageIndex': '${indexNo.value}',
    };
    if (searchStringController.text.trim().isNotEmpty) {
      params['search'] = searchStringController.text.trim();
    }
    final port = _filterOptionValue(selectedFilterPort.value);
    final status = _filterOptionValue(selectedFilterStatus.value);
    final payment = _filterOptionValue(selectedFilterPayment.value);
    if (port.isNotEmpty) params['port'] = port;
    if (status.isNotEmpty) params['status'] = status;
    if (payment.isNotEmpty) params['pay_status'] = payment;
    return 'mobile/containers?${Uri(queryParameters: params).query}';
  }

  Future<void> getContainerFilters() async {
    try {
      final moduleRes =
          await ApiHelper().getDataAuthenticated('mobile/container-filters');
      final data = moduleRes['data'];
      if (data is Map<String, dynamic>) {
        containerFilterOptions.assignAll(data);
      }
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  void clearAdvancedFilters() {
    selectedFilterPort.value = null;
    selectedFilterStatus.value = null;
    selectedFilterPayment.value = null;
  }

  Future<void> getContainerDetail(Containers item) async {
    try {
      selectedContainer.value = item;
      final moduleRes = await ApiHelper()
          .getDataAuthenticated('mobile/containers/${item.id}');
      final data = moduleRes['data'];
      if (data is Map<String, dynamic>) {
        final containerJson = data['container'];
        if (containerJson is Map<String, dynamic>) {
          selectedContainer.value = Containers.fromJson(containerJson);
        }
        final histories = data['email_history'];
        if (histories is List) {
          emailHistoryList.assignAll(histories
              .whereType<Map<String, dynamic>>()
              .map(VehicleEmailHistory.fromJson));
        } else {
          emailHistoryList.clear();
        }
      }
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  Future<void> sendContainerEmail() async {
    final container = selectedContainer.value;
    final sentTo = emailController.text.trim();
    if (container == null) {
      showMightySnackBar(message: 'Container not found');
      return;
    }
    if (!sentTo.isEmail) {
      showMightySnackBar(message: 'Please enter valid email address');
      return;
    }
    try {
      sendingEmail(true);
      final moduleRes = await ApiHelper().postDataAuthenticated(
        'mobile/containers/${container.id}/send-email',
        {'sent_to': sentTo},
      );
      if (moduleRes is Map<String, dynamic> && moduleRes['success'] == false) {
        showMightySnackBar(
          message: moduleRes['message']?.toString() ?? 'Unable to send email',
        );
        return;
      }
      final data = moduleRes['data'];
      if (data is Map<String, dynamic>) {
        emailHistoryList.insert(0, VehicleEmailHistory.fromJson(data));
      } else {
        emailHistoryList.insert(
          0,
          VehicleEmailHistory(
            sentTo: sentTo,
            createdAt: DateTime.now().toIso8601String(),
          ),
        );
      }
      emailController.clear();
      FocusManager.instance.primaryFocus?.unfocus();
      emailHistoryList.refresh();
      showMightySnackBar(message: 'Email sent successfully');
    } catch (error) {
      debugPrint(error.toString());
      final message = error.toString().replaceFirst('Exception: ', '').trim();
      showMightySnackBar(
        message: message.isEmpty ? 'Unable to send email' : message,
      );
    } finally {
      sendingEmail(false);
    }
  }

  AuthController authController = Get.find();
  getContainerFromLocalDatabase() {
    try {
      kIsLoading(true);
      authController.containerDbHelper.selectAll(containerTable).then((value) {
        if (value.isEmpty) {
          // getAllContainerList();
        } else {
          containerList.clear();
          filterContainerList.clear();
          containerList.addAll(value);
          filterContainerList.addAll(value);
        }
      });
    } catch (err) {
      debugPrint(err.toString());
    } finally {
      kIsLoading(false);
    }
  }

  RxList<Containers> serverContainerList = RxList();
  Future<void> getAllContainerList(String containerNo) async {
    // kIsLoading.value = true;
    try {
      if (containerNo.isEmpty) {
        getContainerList(isRefresh: true);
      } else {
        var moduleRes = await ApiHelper().getDataAuthenticated(
            'mobile/containers?PageIndex=1&container_no=${Uri.encodeQueryComponent(containerNo)}&search=${Uri.encodeQueryComponent(containerNo)}');

        ContainerListResponse vlr =
            containerListResponseFromJson(jsonEncode(moduleRes));
        serverContainerList.clear();
        serverContainerList.addAll(vlr.containerList);
        containerList.clear();
        filterContainerList.clear();
        containerList.addAll(vlr.containerList);
        filterContainerList.addAll(vlr.containerList);
      }

      // serverContainerList.value = vlr.containerList;
      // if(containerList.length==0){
      //   await authController.containerDbHelper.truncateTable(containerTable);
      //   vlr.containerList.forEach((element) {
      //     authController.containerDbHelper.save(element, containerTable);
      //
      //   });
      //   getContainerFromLocalDatabase();
      // }
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  RxList<Containers> notificationContainerList = RxList();
  Future<void> getAllContainerListFromNotification(String containerNo) async {
    // kIsLoading.value = true;
    try {
      var moduleRes = await ApiHelper().getDataAuthenticated(
          'mobile/containers?PageIndex=1&container_no=${Uri.encodeQueryComponent(containerNo)}&search=${Uri.encodeQueryComponent(containerNo)}');

      ContainerListResponse vlr =
          containerListResponseFromJson(jsonEncode(moduleRes));
      notificationContainerList.clear();
      notificationContainerList.addAll(vlr.containerList);
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  TextEditingController searchStringController = TextEditingController();
  searchByContainer() {
    getContainerList(isRefresh: true);
  }

  void saveNetworkFile(String fileUrl) async {
    try {
      final path = Uri.parse(fileUrl).path;
      final fileExtension =
          path.contains('.') ? path.substring(path.lastIndexOf('.')) : '.file';
      final responseData = await http.get(Uri.parse(fileUrl));
      if (responseData.statusCode < 200 || responseData.statusCode >= 300) {
        showMightySnackBar(message: 'File could not be downloaded');
        return;
      }
      if (!_looksLikeExpectedFile(responseData.bodyBytes, fileExtension)) {
        debugPrint('Unexpected container document response from $fileUrl');
        showMightySnackBar(message: 'File could not be downloaded');
        return;
      }
      final buffer = responseData.bodyBytes.buffer;
      final byteData = ByteData.view(buffer);
      final tempDir = await getTemporaryDirectory();
      final uniqueName = DateTime.timestamp().toIso8601String();
      final file = await File('${tempDir.path}/$uniqueName$fileExtension')
          .writeAsBytes(buffer.asUint8List(
        byteData.offsetInBytes,
        byteData.lengthInBytes,
      ));
      OpenFile.open(file.path);
    } catch (err) {
      debugPrint(err.toString());
      showMightySnackBar(message: 'File not found');
    }
  }

  bool _looksLikeExpectedFile(List<int> bytes, String extension) {
    if (bytes.length < 4) return false;
    final normalizedExtension = extension.toLowerCase();
    if (normalizedExtension == '.pdf') {
      return bytes[0] == 0x25 &&
          bytes[1] == 0x50 &&
          bytes[2] == 0x44 &&
          bytes[3] == 0x46;
    }
    return true;
  }

  static const duration = Duration(milliseconds: 800);
  Rx<Timer?> searchOnStoppedTyping = Rx<Timer?>(null);
  onChangeHandler(value) async {
    if (value.isNotEmpty) {
      // set the duration that you want call search() after that.
      if (searchOnStoppedTyping.value != null) {
        searchOnStoppedTyping.value!.cancel(); // clear timer
      }
      searchOnStoppedTyping.value = Timer(duration, () async {
        await getContainerList(isRefresh: true);
      });
    } else {
      getContainerList(isRefresh: true);
      searchOnStoppedTyping.value = Timer(duration, () async {
        filterContainerList.clear();
        filterContainerList.addAll(containerList);
      });
    }
  }
}
