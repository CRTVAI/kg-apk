import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:cargo/controllers/vehicle_controller.dart';
import 'package:cargo/utils/global_helpers.dart';
import 'package:http/http.dart' as http;
import 'package:cargo/models/image_file_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'dart:convert';
import 'package:async/async.dart';
import '../config/config.dart';
import '../models/login_response.dart';
import '../models/operator_container_response.dart';
import '../utils/api_helper.dart';
import 'auth_controller.dart';

class OperatorController extends GetxController {
  static final DateFormat _apiDateFormat = DateFormat('yyyy-MM-dd');

  RxBool kIsLoading = false.obs;
  RxList<ImageFileModel> selectedFileList = RxList();
  final RxInt selectedNavigationIndex = 0.obs;

  TextEditingController startDateController = TextEditingController();
  TextEditingController endDateController = TextEditingController();

  DateTime? get selectedStartDate =>
      DateTime.tryParse(startDateController.text.trim());

  DateTime? get selectedEndDate =>
      DateTime.tryParse(endDateController.text.trim());

  String formatApiDate(DateTime date) => _apiDateFormat.format(date);

  void showPickupRequests() {
    selectedNavigationIndex.value = 1;
  }

  void showUploads() {
    selectedNavigationIndex.value = 0;
  }

  RxList<OperatorContainer> containerList = RxList();
  Rx<OperatorContainer?> selectedContainer = Rx<OperatorContainer?>(null);

  void clearAccountData() {
    kIsLoading(false);
    selectedFileList.clear();
    selectedNavigationIndex.value = 0;
    startDateController.clear();
    endDateController.clear();
    containerList.clear();
    selectedContainer.value = null;
    selectedClient.value = null;
  }

  Future<void> getOperatorContainerList() async {
    // kIsLoading.value = true;
    try {
      var moduleRes = await ApiHelper().getDataAuthenticated(
          'operator-containers/${authController.loginResponse.value!.data.user.id}');

      OperatorContainerResponse vlr =
          operatorContainerResponseFromJson(jsonEncode(moduleRes));
      containerList.value = vlr.operatorContainerData.containers;
      containerList.refresh();
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  downloadAndOpenFile(String url) async {
    try {
      final path = Uri.parse(url).path;
      final fileExtention =
          path.contains('.') ? path.substring(path.lastIndexOf('.')) : '.file';
      final http.Response responseData = await http.get(Uri.parse(url));
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
  }

  Future<void> showStartDate(BuildContext context) async {
    final now = DateTime.now();
    final firstDate = DateTime(2015, 8);
    final lastDate = selectedEndDate ?? DateTime(2201);
    var initialDate = selectedStartDate ?? now;
    if (initialDate.isBefore(firstDate)) initialDate = firstDate;
    if (initialDate.isAfter(lastDate)) initialDate = lastDate;

    final DateTime? result = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (result != null) {
      startDateController.text = formatApiDate(result);
    }
  }

  Rx<AppUser?> selectedClient = Rx<AppUser?>(null);
  VehicleController _vehicleController = Get.find();
  changeStatusRequest(int requestId, String status) async {
    try {
      await ApiHelper().postDataAuthenticated('update-pickup-request', {
        'status': '${status}',
        'pickup_request_id': '${requestId}',
      });
      _vehicleController.getAllPickupRequest();
      showMightySnackBar(message: 'Pickup request status updated');
    } catch (err) {
      print(err.toString());
    }
  }

  var colors = [
    Colors.blue,
    Colors.green,
    Colors.pink,
  ];
  List<String> pickupStatusList = ['', 'Approved', 'Waiting', 'Rejected'];

  String? selectedStatus;

  Future<void> showEndDate(BuildContext context) async {
    final now = DateTime.now();
    final firstDate = selectedStartDate ?? DateTime(2015, 8);
    final lastDate = DateTime(2201);
    var initialDate = selectedEndDate ?? now;
    if (initialDate.isBefore(firstDate)) initialDate = firstDate;
    if (initialDate.isAfter(lastDate)) initialDate = lastDate;

    final DateTime? result = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (result != null) {
      endDateController.text = formatApiDate(result);
    }
  }

  Future<Uint8List?> generateThumbnailFromVideo(File videofile) async {
    try {
      final uint8list = await VideoThumbnail.thumbnailData(
        video: videofile.path,
        imageFormat: ImageFormat.JPEG,
        maxWidth:
            128, // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
        quality: 25,
      );
      return uint8list;
    } catch (err) {
      print(err.toString());
      return null;
    }
  }

  pickupFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['jpg', 'png', 'jpeg'],
        // allowedExtensions: ['jpg', 'png', 'jpeg','mp4'],
      );

      if (result != null) {
        List<File> files = result.paths.map((path) => File(path!)).toList();
        files.forEach((element) async {
          Uint8List? uint8list = await generateThumbnailFromVideo(element);
          selectedFileList.add(ImageFileModel(element, uint8list));
        });
        // selectedFileList.addAll(files);
      } else {
        // User canceled the picker
      }
    } catch (err) {
      print(err.toString());
    }
  }

  takePhotoFromCamera() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(source: ImageSource.camera);
      File f = File(photo!.path);
      Uint8List? uint8list = await generateThumbnailFromVideo(f);
      selectedFileList.add(ImageFileModel(f, uint8list));

      selectedFileList.refresh();
    } catch (err) {
      print(err.toString());
    } finally {
      Get.back();
    }
  }

  Future<bool> addFileInRequest(var request) async {
    for (var element in selectedFileList) {
      var stream =
          new http.ByteStream(DelegatingStream.typed(element.file.openRead()));
      // get file length
      var length = await element.file.length();
      var multipartFile = new http.MultipartFile('images[]', stream, length,
          filename: element.file.path);

      request.files.add(multipartFile);
    }
    return true;
  }

  RxBool kUploadingImage = false.obs;
  RxBool showSuccessMessages = false.obs;
  AuthController authController = Get.find();
  uploadFileToContainer() async {
    try {
      if (selectedContainer.value == null) {
        showMightySnackBar(message: 'Please select container first');
      } else {
        kUploadingImage(true);
        var uri = Uri.parse("${kcBaseAPIUrl}send-vehicle-images");
        var request = new http.MultipartRequest("POST", uri);
        if (selectedFileList.isNotEmpty) {
          await addFileInRequest(request);
        }

        // string to uri

        // create multipart request
        request.headers["Authorization"] =
            'Bearer ${authController.accessToken.value}';
        // multipart that takes file

        // add file to multipart
        request.fields['container_number'] =
            '${selectedContainer.value!.containerNo}';

        var response = await request.send();
        print(response.statusCode);
        response.stream.transform(utf8.decoder).listen((value) async {
          print(value);
          var res = jsonDecode(value);
          showSuccessMessage();
          print(res);
        });
      }
    } catch (err) {
      print(err.toString());
      showMightySnackBar(message: 'Please try again');
    } finally {
      kUploadingImage(false);
    }
  }

  showSuccessMessage() async {
    try {
      selectedFileList.clear();
      selectedContainer.value = null;
      showSuccessMessages(true);
      Timer(Duration(seconds: 3), () {
        showSuccessMessages(false);
      });
    } catch (err) {
      print(err.toString());
    }
  }

  takeVideoFromCamera() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickVideo(source: ImageSource.camera);
      File f = File(photo!.path);
      Uint8List? uint8list = await generateThumbnailFromVideo(f);
      selectedFileList.add(ImageFileModel(f, uint8list));

      selectedFileList.refresh();
    } catch (err) {
      print(err.toString());
    } finally {
      Get.back();
    }
  }
}
