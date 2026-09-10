import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:cargo/controllers/auth_controller.dart';
import 'package:cargo/models/pickup_request_response.dart';
import 'package:cargo/models/vehicle_email_history.dart';
import 'package:cargo/models/vehicle_list_response.dart';
import 'package:cargo/utils/api_helper.dart';
import 'package:cargo/utils/global_helpers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:path/path.dart';
import 'package:share_plus/share_plus.dart';
import '../config/config.dart';
import '../models/destination_port_response.dart';

class VehicleController extends GetxController {
  RxBool kIsLoading = false.obs;
  RxInt indexNo = 1.obs;
  RxInt tabIndex = 0.obs;

  RxList<PickupRequest> pickupRequestList = RxList();
  RxBool kPickupRequestLoading = false.obs;
  RxList<PickupRequest> pickupHistoryList = RxList();
  RxBool kPickupHistoryLoading = false.obs;
  RxInt pickupHistoryPage = 1.obs;
  RxMap<String, int> pickupHistoryCounts = <String, int>{
    'waiting': 0,
    'approve': 0,
    'unapprove': 0,
  }.obs;
  TextEditingController pickupHistorySearchController = TextEditingController();
  RxString pickupHistoryStatus = 'all'.obs;
  Rx<DestinationPort?> pickupHistoryDestination = Rx<DestinationPort?>(null);

  Rx<VehicleList?> selectedPickupVehicle = Rx<VehicleList?>(null);

  filterPickupRequest(
      {String? startDate,
      String? endDate,
      String? clientName,
      String? status}) async {
    try {
      kPickupRequestLoading.value = true;
      String url =
          'pickup-requests/${authController.loginResponse.value!.data.user.id}?';
      if (startDate != '' && endDate != '') {
        var lc = url.substring(url.length - 1);
        if (lc == '?') {
          url += 'start_date=$startDate&end_date=$endDate';
        } else {
          url += '&start_date=$startDate&end_date=$endDate';
        }
      }
      if (clientName != null) {
        var lc = url.substring(url.length - 1);
        if (lc == '?') {
          url += 'client=$clientName';
        } else {
          url += '&client=$clientName';
        }
      }
      if (status != null) {
        var lc = url.substring(url.length - 1);
        if (lc == '?') {
          url += 'status=$status';
        } else {
          url += '&status=$status';
        }
      }
      var moduleRes = await ApiHelper().getDataAuthenticated(url);

      PickupRequestResponse vlr =
          pickupRequestResponseFromJson(jsonEncode(moduleRes));
      pickupRequestList.value = vlr.pickupRequestList;

      // kIsLoading.value = false;
    } catch (error) {
      debugPrint(error.toString());
    } finally {
      kPickupRequestLoading.value = false;
    }
  }

  Future<void> getAllPickupRequest() async {
    try {
      kPickupRequestLoading.value = true;
      var moduleRes = await ApiHelper().getDataAuthenticated(
          'pickup-requests/${authController.loginResponse.value!.data.user.id}');

      PickupRequestResponse vlr =
          pickupRequestResponseFromJson(jsonEncode(moduleRes));
      pickupRequestList.value = vlr.pickupRequestList;

      // kIsLoading.value = false;
    } catch (error) {
      debugPrint(error.toString());
    } finally {
      kPickupRequestLoading.value = false;
    }
  }

  Future<void> getPickupHistory({bool resetPage = false}) async {
    try {
      if (resetPage) pickupHistoryPage.value = 1;
      kPickupHistoryLoading.value = true;
      final query = <String, String>{
        'page': pickupHistoryPage.value.toString(),
      };
      final search = pickupHistorySearchController.text.trim();
      if (search.isNotEmpty) query['search'] = search;
      if (pickupHistoryStatus.value != 'all') {
        query['status'] = pickupHistoryStatus.value;
      }
      final destination = pickupHistoryDestination.value;
      if (destination != null) {
        query['destination'] = destination.id.toString();
      }

      final url =
          Uri(path: 'mobile/pickup-history', queryParameters: query).toString();
      final moduleRes = await ApiHelper().getDataAuthenticated(url);
      final payload = moduleRes is Map ? moduleRes['data'] : moduleRes;
      final data = payload is Map<String, dynamic>
          ? payload
          : payload is Map
              ? Map<String, dynamic>.from(payload)
              : <String, dynamic>{};
      final records = _pickupHistoryRecordsFromResponse(moduleRes);
      final parsedRecords = <PickupRequest>[];
      for (final item in records) {
        if (item is! Map) continue;
        try {
          parsedRecords.add(
            PickupRequest.fromJson(Map<String, dynamic>.from(item)),
          );
        } catch (error) {
          debugPrint('Pickup history item skipped: $error');
          parsedRecords.add(_pickupHistoryFallbackRecord(item));
        }
      }
      if (parsedRecords.isEmpty) {
        final fallbackRecords = await _legacyPickupHistoryFallback();
        parsedRecords.addAll(fallbackRecords);
      }
      pickupHistoryList.value = parsedRecords;
      final countsSource = data['counts'];
      final counts = countsSource is Map ? countsSource : {};
      pickupHistoryCounts.value = {
        'waiting': int.tryParse('${counts['waiting'] ?? 0}') ?? 0,
        'approve': int.tryParse('${counts['approve'] ?? 0}') ?? 0,
        'unapprove': int.tryParse('${counts['unapprove'] ?? 0}') ?? 0,
      };
      if (data['destinations'] is List) {
        final destinations = List<DestinationPort>.from(
          (data['destinations'] as List<dynamic>)
              .map((item) => DestinationPort.fromJson(item)),
        );
        destinationPortList.value = destinations;
        final selectedDestination = pickupHistoryDestination.value;
        if (selectedDestination != null) {
          var matched = false;
          for (final destination in destinations) {
            if (destination.id == selectedDestination.id) {
              pickupHistoryDestination.value = destination;
              matched = true;
              break;
            }
          }
          if (!matched) pickupHistoryDestination.value = null;
        }
      }
    } catch (error) {
      debugPrint(error.toString());
    } finally {
      kPickupHistoryLoading.value = false;
    }
  }

  Future<void> resetPickupHistoryFilters() async {
    pickupHistorySearchController.clear();
    pickupHistoryStatus.value = 'all';
    pickupHistoryDestination.value = null;
    await getPickupHistory(resetPage: true);
  }

  List<dynamic> _pickupHistoryRecordsFromResponse(dynamic response) {
    final payload = response is Map ? response['data'] : response;
    final raw = payload is List
        ? payload
        : payload is Map
            ? payload['records'] ??
                payload['list'] ??
                payload['pickups'] ??
                payload['pickup'] ??
                payload['pickup_history'] ??
                payload['pickupHistory'] ??
                payload['data']
            : null;

    if (raw is List) return raw;
    if (raw is Map) {
      if (raw['data'] is List) return raw['data'] as List;
      return raw.values.where(_looksLikePickupHistoryRecord).toList();
    }
    if (payload is Map) {
      return payload.values.where(_looksLikePickupHistoryRecord).toList();
    }
    return <dynamic>[];
  }

  bool _looksLikePickupHistoryRecord(dynamic value) {
    if (value is! Map) return false;
    return value.containsKey('vehicle_id') ||
        value.containsKey('vehicle') ||
        value.containsKey('vehicles') ||
        value.containsKey('pickup_type') ||
        value.containsKey('type') && value.containsKey('status') ||
        value.containsKey('comments') ||
        value.containsKey('file');
  }

  PickupRequest _pickupHistoryFallbackRecord(Map<dynamic, dynamic> item) {
    final vehicleSource = item['vehicle'];
    final vehicleMap = vehicleSource is Map ? vehicleSource : const {};
    return PickupRequest(
      id: int.tryParse('${item['id'] ?? 0}') ?? 0,
      userId: int.tryParse('${item['user_id'] ?? ''}'),
      vehicleId:
          int.tryParse('${item['vehicle_id'] ?? vehicleMap['id'] ?? ''}'),
      comments: _cleanPickupText(item['comments']),
      type: _cleanPickupText(item['type']),
      pickerName: _cleanPickupText(item['picker_name'] ?? item['name']),
      file: _cleanPickupText(item['file']),
      status: _cleanPickupText(item['status']),
      createdAt: DateTime.tryParse('${item['created_at'] ?? ''}'),
      updatedAt: DateTime.tryParse('${item['updated_at'] ?? ''}'),
      paymentStatus: item['payment_status'],
      vehicle: Vehicle(
        id: int.tryParse('${vehicleMap['id'] ?? 0}') ?? 0,
        companyName: vehicleMap['company_name'],
        name: vehicleMap['name'],
        modal: vehicleMap['modal'],
        vin: vehicleMap['vin'],
        lotnumber: vehicleMap['lotnumber'] ?? vehicleMap['lot'],
        destinationPortId: vehicleMap['destination_port_id'],
        destinationManual: vehicleMap['destination_manual'],
      ),
    );
  }

  String? _cleanPickupText(dynamic value) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? null : text;
  }

  Future<List<PickupRequest>> _legacyPickupHistoryFallback() async {
    try {
      final userId = authController.loginResponse.value?.data.user.id;
      if (userId == null) return <PickupRequest>[];
      final response = await ApiHelper().getDataAuthenticated(
        'pickup-requests/$userId',
      );
      final raw = response is Map ? response['data'] : null;
      if (raw is! List) return <PickupRequest>[];
      final records = <PickupRequest>[];
      for (final item in raw) {
        if (item is! Map) continue;
        try {
          records.add(PickupRequest.fromJson(Map<String, dynamic>.from(item)));
        } catch (_) {
          records.add(_pickupHistoryFallbackRecord(item));
        }
      }
      return records.where(_matchesPickupHistoryFilters).toList();
    } catch (error) {
      debugPrint('Pickup history fallback failed: $error');
      return <PickupRequest>[];
    }
  }

  bool _matchesPickupHistoryFilters(PickupRequest request) {
    final status = pickupHistoryStatus.value;
    if (status != 'all' && request.status != status) return false;

    final destination = pickupHistoryDestination.value;
    if (destination != null &&
        request.vehicle?.destinationPortId?.toString() !=
            destination.id.toString()) {
      return false;
    }

    final search = pickupHistorySearchController.text.trim().toLowerCase();
    if (search.isEmpty) return true;
    final vehicle = request.vehicle;
    final haystack = [
      request.id,
      request.type,
      request.pickerName,
      request.comments,
      request.createdAt,
      vehicle?.vin,
      vehicle?.modal,
      vehicle?.companyName,
      vehicle?.name,
      vehicle?.destinationManual,
    ].map((value) => value?.toString().toLowerCase() ?? '').join(' ');
    return haystack.contains(search);
  }

  AuthController authController = Get.find();
  RxList<VehicleList> terminalVehicleList = RxList();
  RxList<VehicleList> serverTerminalVehicleList = RxList();
  RxList<VehicleList> filterTerminalVehicleList = RxList();

  RxList<VehicleList> serverNewVehicleList = RxList();
  RxList<VehicleList> newVehicleList = RxList();
  RxList<VehicleList> filterNewVehicleList = RxList();

  RxList<VehicleList> serverLoadedVehicleList = RxList();
  RxList<VehicleList> loadedVehicleList = RxList();
  RxList<VehicleList> filterLoadedVehicleList = RxList();

  RxList<VehicleList> serverBookedVehicleList = RxList();
  RxList<VehicleList> bookedVehicleList = RxList();
  RxList<VehicleList> filterBookedVehicleList = RxList();

  RxList<VehicleList> serverShippedVehicleList = RxList();
  RxList<VehicleList> shippedVehicleList = RxList();
  RxList<VehicleList> filterShippedVehicleList = RxList();

  RxList<VehicleList> serverDeliveredVehicleList = RxList();
  RxList<VehicleList> deliveredVehicleList = RxList();
  RxList<VehicleList> filterDeliveredVehicleList = RxList();

  TextEditingController pickupRequestCommentController =
      TextEditingController();
  TextEditingController pickupRequesterNameController = TextEditingController();
  RxString pickupRequestType = 'Authorization'.obs;
  RxList<VehicleList> selectedPickupVehicles = <VehicleList>[].obs;
  RxList<VehicleList> pickupEligibleVehicleList = <VehicleList>[].obs;
  RxList<Map<String, dynamic>> previousPickupOptions =
      <Map<String, dynamic>>[].obs;
  Rxn<Map<String, dynamic>> selectedPreviousPickupInfo =
      Rxn<Map<String, dynamic>>();
  RxnString selectedPreviousPickupKey = RxnString();

  RxList<VehicleList> serverReleasedVehicleList = RxList();
  RxList<VehicleList> releasedVehicleList = RxList();
  RxList<VehicleList> filterReleasedVehicleList = RxList();

  RxBool kTerminalLoading = false.obs;

  Rx<File?> pickupRequestFile = Rx<File?>(null);
  RxBool pickupRequestFileSelected = false.obs;
  TextEditingController pickupFileName = TextEditingController();
  selectPickupFile() async {
    try {
      final result = await FilePicker.platform.pickFiles();
      if (result == null || result.files.single.path == null) return;
      final file = File(result.files.single.path!);
      pickupFileName.text = basename(file.path);
      pickupRequestFile.value = file;
      pickupRequestFileSelected(true);
      selectedPreviousPickupInfo.value = null;
      selectedPreviousPickupKey.value = null;
    } catch (err) {
      print(err.toString());
    }
  }

  RxBool kSendingPickupRequestLoading = false.obs;

  Future<bool> sendPickupRequest() async {
    final vehicles = selectedPickupVehicles.isNotEmpty
        ? selectedPickupVehicles.toList()
        : selectedPickupVehicle.value == null
            ? <VehicleList>[]
            : <VehicleList>[selectedPickupVehicle.value!];

    if (vehicles.isEmpty) {
      showMightySnackBar(message: 'Please select at least one vehicle');
      return false;
    }

    if (pickupRequesterNameController.text.trim().isEmpty) {
      showMightySnackBar(message: 'Please enter requester name');
      return false;
    }

    if (pickupRequestType.value.trim().isEmpty) {
      showMightySnackBar(message: 'Please select request type');
      return false;
    }

    kSendingPickupRequestLoading(true);
    try {
      final uri = Uri.parse(
        '${kcBaseAPIUrl}mobile/request-pickup',
      );
      final request = http.MultipartRequest('POST', uri);

      if (pickupRequestFileSelected.isTrue && pickupRequestFile.value != null) {
        final file = pickupRequestFile.value!;
        final stream = http.ByteStream(file.openRead());
        final length = await file.length();
        request.files.add(
          http.MultipartFile(
            'file',
            stream,
            length,
            filename: basename(file.path),
          ),
        );
      }

      request.headers['Authorization'] =
          'Bearer ${authController.accessToken.value}';
      request.fields['vehicle_ids'] =
          vehicles.map((item) => item.vehicle!.id.toString()).join(',');
      request.fields['type'] = pickupRequestType.value;
      request.fields['request_type'] = pickupRequestType.value;
      request.fields['name'] = pickupRequesterNameController.text.trim();
      request.fields['comments'] = pickupRequestCommentController.text.trim();
      final previousInfo = selectedPreviousPickupInfo.value;
      final previousDocument = previousInfo?['document']?.toString().trim();
      if (previousInfo != null && pickupRequestFileSelected.isFalse) {
        request.fields['selected_previous_pickup_info'] =
            previousInfo['id']?.toString() ?? '1';
        if (previousDocument != null && previousDocument.isNotEmpty) {
          request.fields['previous_pickup_document'] = previousDocument;
        }
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      Map<String, dynamic>? responseBody;
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          responseBody = decoded;
        }
      } on FormatException {
        responseBody = null;
      }

      final isSuccessfulStatus =
          response.statusCode >= 200 && response.statusCode < 300;
      final isSuccessfulResponse =
          isSuccessfulStatus && responseBody?['success'] == true;

      if (!isSuccessfulResponse) {
        final data = responseBody?['data'];
        final dataError = data is Map ? data['error']?.toString().trim() : null;
        final message = dataError?.isNotEmpty == true
            ? dataError!
            : responseBody?['message']?.toString().trim();
        showMightySnackBar(
          message: message?.isNotEmpty == true
              ? message!
              : 'Unable to send the pickup request. Please try again.',
        );
        return false;
      }

      showMightySnackBar(message: 'Pickup request sent successfully');
      clearPickupField();
      await getPickupPreference();
      await getVehicleList(isRefresh: true, tabIndex: selectedTabIndex.value);
      await getAllPickupRequest();
      await getPickupEligibleVehicles();
      return true;
    } catch (error) {
      debugPrint('Pickup request failed: $error');
      showMightySnackBar(
        message: 'Unable to send the pickup request. Please try again.',
      );
      return false;
    } finally {
      kSendingPickupRequestLoading(false);
    }
  }

  clearPickupVehicle() {
    selectedPickupVehicle.value = null;
    selectedDestinationPort.value = null;
  }

  clearPickupField() {
    pickupRequestCommentController.clear();
    pickupRequesterNameController.clear();
    pickupRequestType.value = 'Authorization';
    selectedPickupVehicles.clear();
    pickupRequestFile.value = null;
    selectedPreviousPickupInfo.value = null;
    selectedPreviousPickupKey.value = null;

    pickupRequestFileSelected(false);

    pickupFileName.clear();
  }

  Future<void> getPickupEligibleVehicles() async {
    try {
      final moduleRes = await ApiHelper()
          .getDataAuthenticated('mobile/pickup-eligible-vehicles');
      final response = VehicleListResponse.fromJson(moduleRes);
      pickupEligibleVehicleList.value = response.vehicleList;
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  Future<void> getPickupPreference() async {
    try {
      final response =
          await ApiHelper().getDataAuthenticated('mobile/pickup-preference');
      final data = response is Map ? response['data'] : null;
      if (data is! Map) return;

      final options = data['previous_options'];
      if (options is List) {
        final normalized = <Map<String, dynamic>>[];
        var index = 0;
        for (final item in options.whereType<Map>()) {
          final option = Map<String, dynamic>.from(item);
          option['_dropdown_key'] = '${option['id'] ?? index}-$index';
          normalized.add(option);
          index++;
        }
        previousPickupOptions.assignAll(normalized);
      } else {
        previousPickupOptions.clear();
      }
    } catch (error) {
      debugPrint('Pickup preference failed: $error');
    }
  }

  void applyPreviousPickupInfo(Map<String, dynamic>? option) {
    selectedPreviousPickupInfo.value = option;
    selectedPreviousPickupKey.value = option?['_dropdown_key']?.toString();
    if (option == null) {
      pickupRequesterNameController.clear();
      pickupRequestCommentController.clear();
      pickupRequestType.value = 'Authorization';
      pickupRequestFile.value = null;
      pickupRequestFileSelected(false);
      pickupFileName.clear();
      return;
    }

    pickupRequesterNameController.text =
        option['picker_name']?.toString() ?? '';
    pickupRequestCommentController.text = option['comments']?.toString() ?? '';
    final optionType = option['type']?.toString().trim() ?? '';
    final optionRequestType = option['request_type']?.toString().trim() ?? '';
    pickupRequestType.value = optionType.isNotEmpty
        ? optionType
        : optionRequestType.isNotEmpty
            ? optionRequestType
            : 'Authorization';
    final documentName = option['document_name']?.toString().trim() ?? '';
    final document = option['document']?.toString().trim() ?? '';
    pickupRequestFile.value = null;
    pickupRequestFileSelected(false);
    pickupFileName.text = document.isEmpty
        ? ''
        : documentName.isNotEmpty
            ? documentName
            : basename(document);
  }

  void applyPreviousPickupInfoByKey(String? key) {
    if (key == null || key.isEmpty) {
      applyPreviousPickupInfo(null);
      return;
    }

    final option = previousPickupOptions.firstWhereOrNull(
      (item) => item['_dropdown_key']?.toString() == key,
    );
    applyPreviousPickupInfo(option);
  }

  RxList<VehicleImage> warehouseImageList = RxList();
  RxList<VehicleImage> unloadingImageList = RxList();

  getVehicleFilterList(List<VehicleImage> vml) {
    try {
      wareHouseImageList.clear();
      unloadingImageList.clear();
      for (final element in vml) {
        final type = element.type?.toString().toLowerCase() ?? '';
        if (type == 'unloading') {
          unloadingImageList.add(element);
        } else if (type == 'warehouse' || type.isEmpty) {
          wareHouseImageList.add(element);
        }
      }
    } catch (err) {
      print(err.toString());
    }
  }

  TextEditingController notesController = TextEditingController();
  TextEditingController generalNotesController = TextEditingController();
  TextEditingController documentNotesController = TextEditingController();
  TextEditingController customerNameEnglishController = TextEditingController();
  RxBool savingNotes = false.obs;
  RxBool creatingListing = false.obs;
  saveVehicleNotes() async {
    try {
      savingNotes(true);
      await ApiHelper().postDataAuthenticated('mobile/vehicle-notes', {
        'vehicle_id': '${selectedPickupVehicle.value!.vehicle!.id}',
        'notes_user': generalNotesController.text.trim(),
        'notes_document': documentNotesController.text.trim(),
      });

      selectedPickupVehicle.value!.vehicle!.notesUser =
          generalNotesController.text.trim();
      selectedPickupVehicle.value!.vehicle!.notesDocument =
          documentNotesController.text.trim();
      notesController.text = generalNotesController.text.trim();
      await getVehicleList(isRefresh: true, tabIndex: selectedTabIndex.value);
      FocusManager.instance.primaryFocus?.unfocus();
      showMightySnackBar(message: 'Notes saved successfully');
    } catch (err) {
      print(err.toString());
      showMightySnackBar(message: 'Unable to save notes');
    } finally {
      savingNotes(false);
    }
  }

  saveNotes() => saveVehicleNotes();

  updateVehicleInfo() async {
    try {
      final customerName = customerNameEnglishController.text.trim();
      if (selectedDestinationPort.value == null && customerName.isEmpty) {
        showMightySnackBar(
          message: 'Please select destination port or enter customer name',
        );
      } else {
        // savingNotes(true);
        final payload = <String, dynamic>{};
        if (selectedDestinationPort.value != null) {
          payload['destination'] = '${selectedDestinationPort.value!.id}';
        }
        if (customerName.isNotEmpty) {
          payload['customer_name'] = customerName;
          payload['update_customer'] = '1';
        }
        await ApiHelper().postDataAuthenticated(
            'update-vehicle-info/${selectedPickupVehicle.value!.vehicle!.id}',
            payload);

        // notesController.clear();
        // FocusManager.instance.primaryFocus?.unfocus();
        showMightySnackBar(message: 'Destination port updated successfully');
        if (selectedDestinationPort.value != null) {
          selectedPickupVehicle.value!.vehicle!.destinationManual =
              selectedDestinationPort.value!.name;
          selectedPickupVehicle.value!.vehicle!.destinationPort =
              selectedDestinationPort.value;
          selectedPickupVehicle.value!.vehicle!.updateDestination = 1;
        }
        selectedPickupVehicle.value!.vehicle!.customerName = customerName;
        if (customerName.isNotEmpty) {
          selectedPickupVehicle.value!.vehicle!.updateCustomer = 1;
        }
        selectedPickupVehicle.refresh();
      }
    } catch (err) {
      debugPrint(err.toString());
    } finally {
      // savingNotes(false);
    }
  }

  TextEditingController emailController = TextEditingController();
  RxBool sendingEmail = false.obs;
  Future<void> sendEmail(int vehicleId) async {
    final sentTo = emailController.text.trim();
    try {
      if (!sentTo.isEmail) {
        showMightySnackBar(message: 'Please enter valid email address');
        return;
      } else {
        sendingEmail(true);
        final moduleRes =
            await ApiHelper().postDataAuthenticated('send-vehicle', {
          'vehicle_id': '${vehicleId}',
          'email': sentTo,
        });

        if (moduleRes is Map<String, dynamic> &&
            moduleRes['success'] == false) {
          showMightySnackBar(
            message: moduleRes['message']?.toString() ?? 'Unable to send email',
          );
          return;
        }
        final data = moduleRes is Map<String, dynamic>
            ? moduleRes['data'] ?? moduleRes['email_history']
            : null;
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
      }
    } catch (err) {
      debugPrint(err.toString());
      showMightySnackBar(message: 'Unable to send email');
    } finally {
      emailController.clear();
      FocusManager.instance.primaryFocus?.unfocus();
      sendingEmail(false);
    }
  }

  RxBool kVehicleImageLoading = false.obs;
  RxList<VehicleImage> vehicleImageList = RxList();
  RxList<VehicleImage> wareHouseImageList = RxList();
  RxList<VehicleImage> unloadingImagesList = RxList();
  RxBool kDownloadingVehiclePhotos = false.obs;
  RxBool kSharingVehiclePhotos = false.obs;
  filterVehicleImageList() {
    try {
      wareHouseImageList.clear();
      unloadingImagesList.clear();
      vehicleImageList.forEach((element) {
        if (element.type == 'unloading') {
          unloadingImagesList.add(element);
        } else {
          wareHouseImageList.add(element);
        }
      });
    } catch (err) {
      print(err.toString());
    } finally {
      kVehicleImageLoading(false);
    }
  }

  getTerminalVehicleFromLocalDatabase() {
    try {
      kTerminalLoading(true);
      authController.vehicleDbHelper
          .selectAll(terminalVehicleTable)
          .then((value) {
        if (value.length == 0) {
          getTerminalVehicleList();
        } else {
          terminalVehicleList.clear();
          filterTerminalVehicleList.clear();
          terminalVehicleList.addAll(value);
          filterTerminalVehicleList.addAll(value);
        }
      });
    } catch (err) {
      print(err.toString());
    } finally {
      kTerminalLoading(false);
    }
  }

  RxBool kNewLoading = false.obs;
  getNewVehicleFromLocalDatabase() {
    try {
      kNewLoading(true);
      authController.vehicleDbHelper.selectAll(newVehicleTable).then((value) {
        if (value.length == 0) {
          getNewVehicleList();
        } else {
          newVehicleList.clear();
          filterNewVehicleList.clear();
          newVehicleList.addAll(value);
          filterNewVehicleList.addAll(value);
        }
      });
    } catch (err) {
      print(err.toString());
    } finally {
      kNewLoading(false);
    }
  }

  RxBool kLoadedLoading = false.obs;
  getLoadedVehicleFromLocalDatabase() {
    try {
      kLoadedLoading(true);
      authController.vehicleDbHelper
          .selectAll(loadedVehicleTable)
          .then((value) {
        if (value.length == 0) {
          getLoadedVehicleList();
        } else {
          loadedVehicleList.clear();
          filterLoadedVehicleList.clear();
          loadedVehicleList.addAll(value);
          filterLoadedVehicleList.addAll(value);
        }
      });
    } catch (err) {
      print(err.toString());
    } finally {
      kLoadedLoading(false);
    }
  }

  RxBool kBookedLoading = false.obs;
  getBookedVehicleFromLocalDatabase() {
    try {
      kBookedLoading(true);
      authController.vehicleDbHelper
          .selectAll(bookedVehicleTable)
          .then((value) {
        if (value.length == 0) {
          getBookedVehicleList();
        } else {
          bookedVehicleList.clear();
          filterBookedVehicleList.clear();
          bookedVehicleList.addAll(value);
          filterBookedVehicleList.addAll(value);
        }
      });
    } catch (err) {
      print(err.toString());
    } finally {
      kBookedLoading(false);
    }
  }

  RxBool kShippedLoading = false.obs;

  getShippedVehicleFromLocalDatabase() {
    try {
      kShippedLoading(true);
      authController.vehicleDbHelper
          .selectAll(shippedVehicleTable)
          .then((value) {
        if (value.length == 0) {
          getShippedVehicleList();
        } else {
          shippedVehicleList.clear();
          filterShippedVehicleList.clear();
          shippedVehicleList.addAll(value);
          filterShippedVehicleList.addAll(value);
        }
      });
    } catch (err) {
      print(err.toString());
    } finally {
      kShippedLoading(false);
    }
  }

  RxBool kDeliveredLoading = false.obs;

  getDeliveredVehicleFromLocalDatabase() {
    try {
      kDeliveredLoading(true);
      authController.vehicleDbHelper
          .selectAll(deliveredVehicleTable)
          .then((value) {
        if (value.length == 0) {
          getDeliveredVehicleList();
        } else {
          deliveredVehicleList.clear();
          filterDeliveredVehicleList.clear();
          deliveredVehicleList.addAll(value);
          filterDeliveredVehicleList.addAll(value);
        }
      });
    } catch (err) {
      print(err.toString());
    } finally {
      kDeliveredLoading(false);
    }
  }

  RxBool kReleasedLoading = false.obs;
  getReleasedVehicleFromLocalDatabase() {
    try {
      kReleasedLoading(true);
      authController.vehicleDbHelper
          .selectAll(releasedClientVehicleTable)
          .then((value) {
        if (value.length == 0) {
          getReleasedVehicleList();
        } else {
          releasedVehicleList.clear();
          filterReleasedVehicleList.clear();
          releasedVehicleList.addAll(value);
          filterReleasedVehicleList.addAll(value);
        }
      });
    } catch (err) {
      print(err.toString());
    } finally {
      kReleasedLoading(false);
    }
  }

  Rx<VehicleListResponse?> vehicleListResponse = Rx<VehicleListResponse?>(null);
  RxList<VehicleList> vehicleList = RxList();
  RxList<VehicleList> filterVehicleList = RxList();
  RxList<VehicleEmailHistory> emailHistoryList = RxList();
  RxBool kVehicleDetailLoading = false.obs;
  RxBool kVehicleHasMore = true.obs;
  int _vehicleRequestSerial = 0;

  RxMap<String, dynamic> vehicleFilterOptions = <String, dynamic>{}.obs;
  Rxn<dynamic> selectedFilterBuyer = Rxn<dynamic>();
  Rxn<dynamic> selectedFilterTerminal = Rxn<dynamic>();
  Rxn<dynamic> selectedFilterDestination = Rxn<dynamic>();
  Rxn<dynamic> selectedFilterPayment = Rxn<dynamic>();
  Rxn<dynamic> selectedFilterFuel = Rxn<dynamic>();
  Rxn<dynamic> selectedFilterStatus = Rxn<dynamic>();
  Rxn<dynamic> selectedFilterYear = Rxn<dynamic>();
  Rxn<dynamic> selectedFilterMake = Rxn<dynamic>();
  Rxn<dynamic> selectedFilterModel = Rxn<dynamic>();
  TextEditingController purchaseFromController = TextEditingController();
  TextEditingController purchaseToController = TextEditingController();
  TextEditingController deliveryFromController = TextEditingController();
  TextEditingController deliveryToController = TextEditingController();

  refreshVehicle(RefreshController refreshController, int tabIndex) async {
    await getVehicleList(isRefresh: true, tabIndex: tabIndex);
    refreshController.refreshCompleted();
    if (kVehicleHasMore.isTrue) {
      refreshController.resetNoData();
    } else {
      refreshController.loadNoData();
    }
  }

  loadMoreVehicle(RefreshController refreshController, int tabIndex) async {
    try {
      if (kLoadingVehicle.isTrue) return;
      if (kVehicleHasMore.isFalse) {
        refreshController.loadNoData();
        return;
      }
      await getVehicleList(isRefresh: false, tabIndex: tabIndex);
      if (kVehicleHasMore.isTrue) {
        refreshController.loadComplete();
      } else {
        refreshController.loadNoData();
      }
    } catch (err) {
      debugPrint(err.toString());
      refreshController.loadFailed();
    }
  }

  RxInt selectedTabIndex = 0.obs;

  List<String> tabOptions = [
    'All Vehicle',
    'At Terminal',
    'New',
    'Loaded',
    'Booked',
    'Shipped',
    'Delivered',
    'Released to client'
  ];
  RxBool kLoadingVehicle = false.obs;

  void clearAccountData() {
    pickupRequestList.clear();
    pickupHistoryList.clear();
    selectedPickupVehicle.value = null;
    terminalVehicleList.clear();
    serverTerminalVehicleList.clear();
    filterTerminalVehicleList.clear();
    serverNewVehicleList.clear();
    newVehicleList.clear();
    filterNewVehicleList.clear();
    serverLoadedVehicleList.clear();
    loadedVehicleList.clear();
    filterLoadedVehicleList.clear();
    serverBookedVehicleList.clear();
    bookedVehicleList.clear();
    filterBookedVehicleList.clear();
    serverShippedVehicleList.clear();
    shippedVehicleList.clear();
    filterShippedVehicleList.clear();
    serverDeliveredVehicleList.clear();
    deliveredVehicleList.clear();
    filterDeliveredVehicleList.clear();
    selectedPickupVehicles.clear();
    pickupEligibleVehicleList.clear();
    previousPickupOptions.clear();
    serverReleasedVehicleList.clear();
    releasedVehicleList.clear();
    filterReleasedVehicleList.clear();
    warehouseImageList.clear();
    unloadingImageList.clear();
    vehicleImageList.clear();
    wareHouseImageList.clear();
    unloadingImagesList.clear();
    vehicleListResponse.value = null;
    vehicleList.clear();
    filterVehicleList.clear();
    emailHistoryList.clear();
    vehicleFilterOptions.clear();
    selectedDestinationPort.value = null;
    notificationVehicleList.clear();
    selectedTabIndex.value = 0;
    kVehicleHasMore(true);
    searchOnStoppedTyping.value?.cancel();
    searchStringController.clear();
    clearAdvancedFilters();
    clearPickupField();
    generalNotesController.clear();
    documentNotesController.clear();
    emailController.clear();
  }

  String _filterOptionValue(dynamic option) {
    if (option is Map) {
      return (option['id'] ?? option['value'] ?? '').toString();
    }
    return option?.toString() ?? '';
  }

  Future<void> getVehicleFilters() async {
    try {
      final moduleRes =
          await ApiHelper().getDataAuthenticated('mobile/vehicle-filters');
      final data = moduleRes['data'];
      if (data is Map<String, dynamic>) {
        vehicleFilterOptions.assignAll(data);
      }
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  void clearAdvancedFilters() {
    selectedFilterBuyer.value = null;
    selectedFilterTerminal.value = null;
    selectedFilterDestination.value = null;
    selectedFilterPayment.value = null;
    selectedFilterFuel.value = null;
    selectedFilterStatus.value = null;
    selectedFilterYear.value = null;
    selectedFilterMake.value = null;
    selectedFilterModel.value = null;
    purchaseFromController.clear();
    purchaseToController.clear();
    deliveryFromController.clear();
    deliveryToController.clear();
  }

  void clearVehicleSearchAndFilters() {
    searchOnStoppedTyping.value?.cancel();
    searchStringController.clear();
    clearAdvancedFilters();
  }

  dynamic _statusFilterOptionForName(String statusName) {
    final statuses = vehicleFilterOptions['statuses'];
    if (statuses is! List) return null;
    final normalizedStatus = statusName.trim().toLowerCase();
    for (final status in statuses) {
      if (status is Map) {
        final name =
            (status['name'] ?? status['label'] ?? status['value'] ?? '')
                .toString()
                .trim()
                .toLowerCase();
        if (name == normalizedStatus) return status;
      } else if (status.toString().trim().toLowerCase() == normalizedStatus) {
        return status;
      }
    }
    return null;
  }

  Future<void> openVehicleStatusFromDashboard(int tabIndex) async {
    clearVehicleSearchAndFilters();
    final statusName = _vehicleStatusForTab(tabIndex);
    selectedTabIndex.value = 0;
    if (statusName.isNotEmpty) {
      final statuses = vehicleFilterOptions['statuses'];
      if (statuses is! List || statuses.isEmpty) {
        await getVehicleFilters();
      }
      final statusOption = _statusFilterOptionForName(statusName);
      if (statusOption != null) {
        selectedFilterStatus.value = statusOption;
      } else {
        selectedTabIndex.value = tabIndex;
      }
    }
    vehicleList.clear();
    filterVehicleList.clear();
    await getVehicleList(isRefresh: true, tabIndex: selectedTabIndex.value);
  }

  String _vehicleStatusForTab(int tabIndex) {
    if (tabIndex == 1) return 'At Terminal';
    if (tabIndex == 2) return 'New';
    if (tabIndex == 3) return 'Loaded';
    if (tabIndex == 4) return 'Booked';
    if (tabIndex == 5) return 'Shipped';
    if (tabIndex == 6) return 'Delivered';
    if (tabIndex == 7) return 'Released to client';
    return '';
  }

  String _vehicleListEndpoint(int tabIndex) {
    final statusFromTab = _vehicleStatusForTab(tabIndex);
    final params = <String, String>{
      'PageIndex': '${indexNo.value}',
    };
    if (statusFromTab.isNotEmpty) params['Status'] = statusFromTab;
    if (searchStringController.text.trim().isNotEmpty) {
      params['search'] = searchStringController.text.trim();
      params['vin'] = searchStringController.text.trim();
    }
    final buyer = _filterOptionValue(selectedFilterBuyer.value);
    final terminal = _filterOptionValue(selectedFilterTerminal.value);
    final destination = _filterOptionValue(selectedFilterDestination.value);
    final payment = _filterOptionValue(selectedFilterPayment.value);
    final fuel = _filterOptionValue(selectedFilterFuel.value);
    final status = _filterOptionValue(selectedFilterStatus.value);
    final year = _filterOptionValue(selectedFilterYear.value);
    final make = _filterOptionValue(selectedFilterMake.value);
    final model = _filterOptionValue(selectedFilterModel.value);
    if (buyer.isNotEmpty) params['buyer'] = buyer;
    if (terminal.isNotEmpty) params['terminal'] = terminal;
    if (destination.isNotEmpty) params['destination'] = destination;
    if (payment.isNotEmpty) params['pay_status'] = payment;
    if (fuel.isNotEmpty) params['fuel_type'] = fuel;
    if (status.isNotEmpty) params['status'] = status;
    if (year.isNotEmpty) params['year'] = year;
    if (make.isNotEmpty) params['make'] = make;
    if (model.isNotEmpty) params['model'] = model;
    if (purchaseFromController.text.trim().isNotEmpty) {
      params['fromPurchaseDate'] = purchaseFromController.text.trim();
    }
    if (purchaseToController.text.trim().isNotEmpty) {
      params['toPurchaseDate'] = purchaseToController.text.trim();
    }
    if (deliveryFromController.text.trim().isNotEmpty) {
      params['fromDeliveryDate'] = deliveryFromController.text.trim();
    }
    if (deliveryToController.text.trim().isNotEmpty) {
      params['toDeliveryDate'] = deliveryToController.text.trim();
    }
    return 'mobile/vehicles?${Uri(queryParameters: params).query}';
  }

  Future<void> getVehicleList({bool? isRefresh, required int tabIndex}) async {
    final refresh = isRefresh ?? true;
    if (!refresh && (kLoadingVehicle.isTrue || kVehicleHasMore.isFalse)) {
      return;
    }
    final requestSerial = ++_vehicleRequestSerial;
    try {
      if (refresh) {
        indexNo.value = 1;
        kVehicleHasMore.value = true;
        kLoadingVehicle(true);
      } else {
        kLoadingVehicle(true);
      }
      var moduleRes = await ApiHelper()
          .getDataAuthenticated(_vehicleListEndpoint(tabIndex));

      if (requestSerial != _vehicleRequestSerial) return;

      VehicleListResponse vlr =
          vehicleListResponseFromJson(jsonEncode(moduleRes));
      final receivedVehicles = vlr.vehicleList;

      if (refresh) {
        vehicleList.clear();
        filterVehicleList.clear();
        vehicleList.addAll(receivedVehicles);
        filterVehicleList.addAll(receivedVehicles);
      } else {
        vehicleList.addAll(receivedVehicles);
        filterVehicleList.addAll(receivedVehicles);
        vehicleList.refresh();
        filterVehicleList.refresh();
      }

      kVehicleHasMore.value = receivedVehicles.length >= 20;
      if (receivedVehicles.isNotEmpty) {
        indexNo.value += 1;
        indexNo.refresh();
      }
    } catch (error) {
      debugPrint(error.toString());
    } finally {
      if (requestSerial == _vehicleRequestSerial) {
        kLoadingVehicle(false);
      }
    }
  }

  Future<void> refreshVehicleListNow({
    RefreshController? refreshController,
    required int tabIndex,
  }) async {
    searchOnStoppedTyping.value?.cancel();
    await getVehicleList(isRefresh: true, tabIndex: tabIndex);
    refreshController?.refreshCompleted();
    if (kVehicleHasMore.isTrue) {
      refreshController?.resetNoData();
    } else {
      refreshController?.loadNoData();
    }
  }

  Future<void> getVehicleDetail(VehicleList vehicleListItem) async {
    try {
      kVehicleDetailLoading(true);
      selectedPickupVehicle.value = vehicleListItem;
      final moduleRes = await ApiHelper()
          .getDataAuthenticated('mobile/vehicles/${vehicleListItem.id}');
      final data = moduleRes['data'];
      if (data is Map<String, dynamic>) {
        final vehicleJson = data['vehicle'];
        if (vehicleJson is Map<String, dynamic>) {
          selectedPickupVehicle.value = VehicleList.fromJson(vehicleJson);
          final vehicle = selectedPickupVehicle.value?.vehicle;
          generalNotesController.text = vehicle?.notesUser?.toString() ?? '';
          documentNotesController.text =
              vehicle?.notesDocument?.toString() ?? '';
          notesController.text = generalNotesController.text;
          customerNameEnglishController.text =
              vehicle?.customerName?.toString() ?? '';
          _syncSelectedDestinationPort(vehicle);
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
    } finally {
      kVehicleDetailLoading(false);
    }
  }

  Future<bool> createCentralDispatchListing(
    VehicleList vehicleListItem, {
    required String balanceAmount,
    required String codAmount,
    required String additionalInfo,
    required String predispatchNotes,
    required String transportationReleaseNotes,
  }) async {
    try {
      creatingListing(true);
      final moduleRes = await ApiHelper().postDataAuthenticated(
        'mobile/vehicles/${vehicleListItem.id}/create-listing',
        {
          'balance_amount': balanceAmount,
          'cod_amount': codAmount,
          'additional_info': additionalInfo,
          'predispatch_notes': predispatchNotes,
          'transportation_release_notes': transportationReleaseNotes,
        },
      );
      if (moduleRes['success'] == true) {
        showMightySnackBar(
          message: moduleRes['message']?.toString() ??
              'Listing created successfully',
        );
        await getVehicleDetail(vehicleListItem);
        return true;
      }
      showMightySnackBar(
        message: moduleRes['message']?.toString() ?? 'Unable to create listing',
      );
      return false;
    } catch (error) {
      debugPrint(error.toString());
      showMightySnackBar(message: 'Unable to create listing');
      return false;
    } finally {
      creatingListing(false);
    }
  }

  saveVehicleImageList(
      List<VehicleImage> vehicleImageList, String tableName) async {
    if (vehicleImageList.length > 0) {
      await authController.vehicleDbHelper.truncateTable(tableName);
      vehicleImageList.forEach((element) {
        authController.vehicleImageDbHelper.save(element, tableName);
      });
    }
  }

  RxList<DestinationPort> destinationPortList = RxList();
  RxList<DestinationPort> shippingLineList = RxList();
  Rx<DestinationPort?> selectedDestinationPort = Rx<DestinationPort?>(null);

  void _syncSelectedDestinationPort(Vehicle? vehicle) {
    if (vehicle == null || destinationPortList.isEmpty) return;
    final destinationId = vehicle.destinationPortId?.toString();
    if (destinationId == null || destinationId.isEmpty) return;
    for (final destination in destinationPortList) {
      if (destination.id.toString() == destinationId) {
        selectedDestinationPort.value = destination;
        return;
      }
    }
  }

  getDestinationPortList() async {
    try {
      // kIsLoading.value = true;
      var moduleRes =
          await ApiHelper().getDataAuthenticated('destination-port');

      DestinationPortResponse vlr =
          destinationPortResponseFromJson(jsonEncode(moduleRes));
      destinationPortList.value = vlr.destinationData.destinationList!;
      shippingLineList.value = vlr.destinationData.shippingLineList!;
      _syncSelectedDestinationPort(selectedPickupVehicle.value?.vehicle);
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  Future<void> getTerminalVehicleList() async {
    try {
      // kIsLoading.value = true;
      final vehicles = await _getAllVehiclesByStatus(
        'At Terminal',
      );
      serverTerminalVehicleList.value = vehicles;
      terminalVehicleList.clear();
      filterTerminalVehicleList.clear();
      terminalVehicleList.addAll(vehicles);
      filterTerminalVehicleList.addAll(vehicles);
      // if(terminalVehicleList.length==0){
      //   await authController.vehicleDbHelper.truncateTable(terminalVehicleTable);
      //   vlr.vehicleList.forEach((element){
      //     authController.vehicleDbHelper.save(element, terminalVehicleTable);
      //     saveVehicleImageList(element.vehicle.vehicleImages,terminalVehicleImageTable);
      //   });
      //   getTerminalVehicleFromLocalDatabase();
      // }

      // kIsLoading.value = false;
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  getNewVehicleList() async {
    try {
      // kIsLoading.value = true;
      final vehicles = await _getAllVehiclesByStatus('New');
      serverNewVehicleList.value = vehicles;
      newVehicleList.clear();
      filterNewVehicleList.clear();
      newVehicleList.addAll(vehicles);
      filterNewVehicleList.addAll(vehicles);
      // if(newVehicleList.length==0){
      //   await authController.vehicleDbHelper.truncateTable(newVehicleTable);
      //   vlr.vehicleList.forEach((element) {
      //     authController.vehicleDbHelper.save(element, newVehicleTable);
      //     saveVehicleImageList(element.vehicle.vehicleImages,newVehicleImageTable);
      //   });
      //   getNewVehicleFromLocalDatabase();
      // }

      // kIsLoading.value = false;
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  getLoadedVehicleList() async {
    try {
      // kIsLoading.value = true;
      final vehicles = await _getAllVehiclesByStatus('Loaded');
      serverLoadedVehicleList.value = vehicles;

      loadedVehicleList.clear();
      filterLoadedVehicleList.clear();
      loadedVehicleList.addAll(vehicles);
      filterLoadedVehicleList.addAll(vehicles);
      // if(loadedVehicleList.length==0){
      //   await authController.vehicleDbHelper.truncateTable(loadedVehicleTable);
      //   vlr.vehicleList.forEach((element) {
      //     authController.vehicleDbHelper.save(element, loadedVehicleTable);
      //     saveVehicleImageList(element.vehicle.vehicleImages,loadedVehicleImageTable);
      //   });
      //   getLoadedVehicleFromLocalDatabase();
      // }

      // kIsLoading.value = false;
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  getBookedVehicleList() async {
    try {
      // kIsLoading.value = true;
      final vehicles = await _getAllVehiclesByStatus('Booked');
      serverBookedVehicleList.value = vehicles;
      bookedVehicleList.clear();
      filterBookedVehicleList.clear();
      bookedVehicleList.addAll(vehicles);
      filterBookedVehicleList.addAll(vehicles);
      // if(bookedVehicleList.length==0){
      //   await authController.vehicleDbHelper.truncateTable(bookedVehicleTable);
      //   vlr.vehicleList.forEach((element) {
      //     authController.vehicleDbHelper.save(element, bookedVehicleTable);
      //     saveVehicleImageList(element.vehicle.vehicleImages,bookedVehicleImageTable);
      //   });
      //   getBookedVehicleFromLocalDatabase();
      // }

      // kIsLoading.value = false;
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  Future<void> getShippedVehicleList() async {
    try {
      // kIsLoading.value = true;
      final vehicles = await _getAllVehiclesByStatus(
        'Shipped',
      );
      serverShippedVehicleList.value = vehicles;
      shippedVehicleList.clear();
      filterShippedVehicleList.clear();
      shippedVehicleList.addAll(vehicles);
      filterShippedVehicleList.addAll(vehicles);
      // if(shippedVehicleList.length==0){
      //   await authController.vehicleDbHelper.truncateTable(shippedVehicleTable);
      //   vlr.vehicleList.forEach((element) {
      //     authController.vehicleDbHelper.save(element, shippedVehicleTable);
      //     saveVehicleImageList(element.vehicle.vehicleImages,shippedVehicleImageTable);
      //   });
      //   getShippedVehicleFromLocalDatabase();
      // }

      // kIsLoading.value = false;
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  Future<void> getDeliveredVehicleList() async {
    try {
      // kIsLoading.value = true;
      final vehicles = await _getAllVehiclesByStatus(
        'Delivered',
      );
      serverDeliveredVehicleList.value = vehicles;
      deliveredVehicleList.clear();
      filterDeliveredVehicleList.clear();
      deliveredVehicleList.addAll(vehicles);
      filterDeliveredVehicleList.addAll(vehicles);
      // if(deliveredVehicleList.length==0){
      //   await authController.vehicleDbHelper.truncateTable(deliveredVehicleTable);
      //   vlr.vehicleList.forEach((element) {
      //     authController.vehicleDbHelper.save(element, deliveredVehicleTable);
      //     saveVehicleImageList(element.vehicle.vehicleImages,deliveredVehicleImageTable);
      //   });
      //   getDeliveredVehicleFromLocalDatabase();
      // }

      // kIsLoading.value = false;
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  Future<List<VehicleList>> _getAllVehiclesByStatus(String status) async {
    final vehicles = <VehicleList>[];
    var page = 1;
    while (true) {
      final endpoint =
          'vehicles?PageIndex=$page&Status=${Uri.encodeQueryComponent(status)}';
      final moduleRes = await ApiHelper().getDataAuthenticated(endpoint);
      final response = vehicleListResponseFromJson(jsonEncode(moduleRes));
      final pageVehicles = response.vehicleList;
      vehicles.addAll(pageVehicles);
      if (pageVehicles.length < 20) break;
      page += 1;
    }
    return vehicles;
  }

  void saveNetworkImage(var imageUrl) async {
    try {
      final path = Uri.parse(imageUrl).path;
      final fileExtention =
          path.contains('.') ? path.substring(path.lastIndexOf('.')) : '.file';
      final http.Response responseData = await http.get(Uri.parse(imageUrl));
      var uint8list = responseData.bodyBytes;
      var buffer = uint8list.buffer;
      ByteData byteData = ByteData.view(buffer);
      String uniqueName = DateTime.timestamp().toIso8601String();
      var tempDir = await getTemporaryDirectory();
      File file = await File('${tempDir.path}/${uniqueName}$fileExtention')
          .writeAsBytes(buffer.asUint8List(
              byteData.offsetInBytes, byteData.lengthInBytes));

      OpenFile.open(file.path);
    } catch (err) {
      print(err.toString());
      showMightySnackBar(message: 'File not found');
    }
    // GallerySaver.saveImage(imageUrl).then((success) {
    //     print(success);
    //     showMightySnackBar(message: 'Image downloaded successfully');
    // });
  }

  Future<void> saveNetworkImagesToGallery(
    List<String> imageUrls, {
    String albumName = 'KG Auto',
  }) async {
    final urls = imageUrls
        .map((url) => url.trim())
        .where((url) => url.isNotEmpty)
        .toSet()
        .toList();
    if (urls.isEmpty) {
      showMightySnackBar(message: 'No photos available to download');
      return;
    }

    try {
      kDownloadingVehiclePhotos(true);
      var savedCount = 0;
      for (final url in urls) {
        final saved = await GallerySaver.saveImage(
          url,
          albumName: albumName,
        );
        if (saved == true) {
          savedCount++;
        }
      }

      if (savedCount == 0) {
        showMightySnackBar(message: 'Photos could not be downloaded');
        return;
      }

      showMightySnackBar(
        message:
            '$savedCount ${savedCount == 1 ? 'photo' : 'photos'} saved to gallery',
      );
    } catch (err) {
      debugPrint(err.toString());
      showMightySnackBar(message: 'Unable to download photos');
    } finally {
      kDownloadingVehiclePhotos(false);
    }
  }

  Future<void> shareNetworkImages(
    List<String> imageUrls, {
    String subject = 'KG Auto vehicle photos',
  }) async {
    final urls = imageUrls
        .map((url) => url.trim())
        .where((url) => url.isNotEmpty)
        .toSet()
        .toList();
    if (urls.isEmpty) {
      showMightySnackBar(message: 'No photos available to share');
      return;
    }

    try {
      kSharingVehiclePhotos(true);
      final files = <XFile>[];
      for (var index = 0; index < urls.length; index++) {
        final url = urls[index];
        final uri = Uri.parse(url);
        final file = await DefaultCacheManager().getSingleFile(url);
        final path = uri.path;
        final name = path.contains('/') && path.split('/').last.isNotEmpty
            ? path.split('/').last
            : 'vehicle_photo_${index + 1}.jpg';
        files.add(XFile(file.path, mimeType: 'image/jpeg', name: name));
      }

      if (files.isEmpty) {
        showMightySnackBar(message: 'Photos could not be prepared for sharing');
        return;
      }

      await Share.shareXFiles(files, subject: subject);
    } catch (err) {
      debugPrint(err.toString());
      showMightySnackBar(message: 'Unable to share photos');
    } finally {
      kSharingVehiclePhotos(false);
    }
  }

  getReleasedVehicleList() async {
    try {
      // kIsLoading.value = true;
      var moduleRes = await ApiHelper().getDataAuthenticated(
          'vehicles?PageIndex=${indexNo.value}&Status=Released to client');

      VehicleListResponse vlr =
          vehicleListResponseFromJson(jsonEncode(moduleRes));
      serverReleasedVehicleList.value = vlr.vehicleList;
      releasedVehicleList.clear();
      filterReleasedVehicleList.clear();
      releasedVehicleList.addAll(vlr.vehicleList);
      filterReleasedVehicleList.addAll(vlr.vehicleList);
      // if(releasedVehicleList.length==0){
      //   await authController.vehicleDbHelper.truncateTable(releasedClientVehicleTable);
      //   vlr.vehicleList.forEach((element) {
      //     authController.vehicleDbHelper.save(element, releasedClientVehicleTable);
      //     saveVehicleImageList(element.vehicle.vehicleImages,releasedVehicleImageTable);
      //   });
      //   getReleasedVehicleFromLocalDatabase();
      // }

      // kIsLoading.value = false;
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  Future<void> getAllVehicleList(String vin) async {
    try {
      // kIsLoading.value = true;
      if (vin.isEmpty) {
        getVehicleList(tabIndex: selectedTabIndex.value, isRefresh: true);
      } else {
        var moduleRes = await ApiHelper().getDataAuthenticated(
            'mobile/vehicles?PageIndex=1&vin=${Uri.encodeQueryComponent(vin)}&search=${Uri.encodeQueryComponent(vin)}');

        VehicleListResponse vlr =
            vehicleListResponseFromJson(jsonEncode(moduleRes));
        vehicleList.clear();
        filterVehicleList.clear();
        vehicleList.addAll(vlr.vehicleList);
        filterVehicleList.addAll(vlr.vehicleList);
      }

      // kIsLoading.value = false;
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  RxList<VehicleList> notificationVehicleList = RxList();
  Future<void> getAllVehicleListFromNotification(String vin) async {
    try {
      var moduleRes = await ApiHelper()
          .getDataAuthenticated('vehicles?PageIndex=1&&vin=${vin}');

      VehicleListResponse vlr =
          vehicleListResponseFromJson(jsonEncode(moduleRes));
      notificationVehicleList.clear();
      notificationVehicleList.addAll(vlr.vehicleList);
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  List<VehicleImage> getVehicleImageList(String type, int vehicleId) {
    List<VehicleImage> vehicleImageList = [];
    try {
      vehicleImageList = filterVehicleList
          .firstWhere((element) => element.vehicle!.id == vehicleId)
          .vehicle!
          .vehicleImages!;
    } catch (err) {
      print(err.toString());
    } finally {
      return vehicleImageList;
    }
  }

  TextEditingController searchStringController = TextEditingController();
  Future<void> searchByVin() async {
    searchOnStoppedTyping.value?.cancel();
    await getVehicleList(tabIndex: selectedTabIndex.value, isRefresh: true);
    // if(searchStringController.text.isEmpty){
    //   filterVehicleList.clear();
    //   filterVehicleList.addAll(vehicleList);
    // }else{
    //
    //   filterVehicleList.clear();
    //   vehicleList.forEach((element) {
    //     if(element.vehicle!.vin.toUpperCase().contains(searchStringController.text.toUpperCase())){
    //       filterVehicleList.add(element);
    //     }
    //   });
    //
    //   filterVehicleList.refresh();
    // }
    // if(tabIndex==0){
    //   if(searchStringController.text.isEmpty){
    //     filterTerminalVehicleList.clear();
    //     filterTerminalVehicleList.addAll(terminalVehicleList);
    //   }else{
    //     filterTerminalVehicleList.clear();
    //     terminalVehicleList.forEach((element) {
    //       if(element.vehicle!.vin.toUpperCase().contains(searchStringController.text.toUpperCase())){
    //         filterTerminalVehicleList.add(element);
    //       }
    //     });
    //     filterTerminalVehicleList.refresh();
    //   }
    // }
    // else if(tabIndex==1){
    //   if(searchStringController.text.isEmpty){
    //     filterNewVehicleList.clear();
    //     filterNewVehicleList.addAll(newVehicleList);
    //   }else{
    //     filterNewVehicleList.clear();
    //     newVehicleList.forEach((element) {
    //       if(element.vehicle!.vin.toUpperCase().contains(searchStringController.text.toUpperCase())){
    //         filterNewVehicleList.add(element);
    //       }
    //     });
    //     filterNewVehicleList.refresh();
    //   }
    // }
    // else if(tabIndex==2){
    //   if(searchStringController.text.isEmpty){
    //     filterLoadedVehicleList.clear();
    //     filterLoadedVehicleList.addAll(loadedVehicleList);
    //   }else{
    //     filterLoadedVehicleList.clear();
    //     loadedVehicleList.forEach((element) {
    //       if(element.vehicle!.vin.toUpperCase().contains(searchStringController.text.toUpperCase())){
    //         filterLoadedVehicleList.add(element);
    //       }
    //     });
    //     filterLoadedVehicleList.refresh();
    //   }
    // }
    // else if(tabIndex==3){
    //   if(searchStringController.text.isEmpty){
    //     filterBookedVehicleList.clear();
    //     filterBookedVehicleList.addAll(bookedVehicleList);
    //   }else{
    //     filterBookedVehicleList.clear();
    //     bookedVehicleList.forEach((element) {
    //       if(element.vehicle!.vin.toUpperCase().contains(searchStringController.text.toUpperCase())){
    //         filterBookedVehicleList.add(element);
    //       }
    //     });
    //     filterBookedVehicleList.refresh();
    //   }
    // }
    // else if(tabIndex==4){
    //   if(searchStringController.text.isEmpty){
    //     filterShippedVehicleList.clear();
    //     filterShippedVehicleList.addAll(shippedVehicleList);
    //   }else{
    //     filterShippedVehicleList.clear();
    //     shippedVehicleList.forEach((element) {
    //       if(element.vehicle!.vin.toUpperCase().contains(searchStringController.text.toUpperCase())){
    //         filterShippedVehicleList.add(element);
    //       }
    //     });
    //     filterShippedVehicleList.refresh();
    //   }
    // }
    // else if(tabIndex==5){
    //   if(searchStringController.text.isEmpty){
    //     filterDeliveredVehicleList.clear();
    //     filterDeliveredVehicleList.addAll(deliveredVehicleList);
    //   }else{
    //     filterDeliveredVehicleList.clear();
    //     deliveredVehicleList.forEach((element) {
    //       if(element.vehicle!.vin.toUpperCase().contains(searchStringController.text.toUpperCase())){
    //         filterDeliveredVehicleList.add(element);
    //       }
    //     });
    //     filterDeliveredVehicleList.refresh();
    //   }
    // }
    // else if(tabIndex==6){
    //   if(searchStringController.text.isEmpty){
    //     filterReleasedVehicleList.clear();
    //     filterReleasedVehicleList.addAll(releasedVehicleList);
    //   }else{
    //     filterReleasedVehicleList.clear();
    //     releasedVehicleList.forEach((element) {
    //       if(element.vehicle!.vin.toUpperCase().contains(searchStringController.text.toUpperCase())){
    //         filterReleasedVehicleList.add(element);
    //       }
    //     });
    //     filterReleasedVehicleList.refresh();
    //   }
    // }
  }

  void _applyInstantVinFilter(String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) {
      filterVehicleList
        ..clear()
        ..addAll(vehicleList);
      return;
    }

    final matches = vehicleList.where((item) {
      final vehicle = item.vehicle;
      final haystack = [
        vehicle?.vin,
        vehicle?.lotnumber,
        vehicle?.modal,
        vehicle?.companyName,
        vehicle?.name,
      ].map((value) => value?.toString().toLowerCase() ?? '').join(' ');
      return haystack.contains(normalized);
    }).toList();

    filterVehicleList
      ..clear()
      ..addAll(matches);
  }

  static const duration = Duration(milliseconds: 250);
  Rx<Timer?> searchOnStoppedTyping = Rx<Timer?>(null);
  onChangeHandler(value) async {
    searchOnStoppedTyping.value?.cancel();
    _applyInstantVinFilter(value?.toString() ?? '');
    if (value.isNotEmpty) {
      searchOnStoppedTyping.value = Timer(duration, () async {
        await getVehicleList(tabIndex: selectedTabIndex.value, isRefresh: true);
      });
    } else {
      await getVehicleList(tabIndex: selectedTabIndex.value, isRefresh: true);
    }
  }
}
