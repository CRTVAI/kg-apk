import 'dart:async';

import 'package:cargo/controllers/container_controller.dart';
import 'package:cargo/controllers/home_controller.dart';
import 'package:cargo/controllers/operator_controller.dart';
import 'package:cargo/controllers/transaction_controller.dart';
import 'package:cargo/controllers/user_controller.dart';
import 'package:cargo/controllers/vehicle_controller.dart';
import 'package:cargo/local_db/container_db_helper.dart';
import 'package:cargo/local_db/vehicle_image_db_helper.dart';
import 'package:cargo/ui/home/home_screen.dart';
import 'package:cargo/ui/home/operator_home_screen.dart';
import 'package:cargo/utils/global_helpers.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../local_db/Db.dart';
import '../local_db/vehicle_db_helper.dart';
import '../models/login_response.dart';
import '../ui/auth/login_screen.dart';
import '../utils/api_helper.dart';
import '../utils/mighty_exception.dart';

class AuthController extends GetxController {
  RxBool kIsLoading = false.obs;
  RxBool kIsPasswordVisible = false.obs;
  RxBool kLoginComplete = false.obs;
  RxBool kForgotPasswordLoading = false.obs;
  RxBool kForgotPasswordSubmitted = false.obs;
  late SharedPreferences prefs;

  RxString accessToken = ''.obs;
  RxBool loginSuccessfull = false.obs;

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController forgotPasswordEmailController = TextEditingController();

  Future<void> loginForm() async {
    final username = emailController.text.trim();
    final password = passwordController.text;
    if (username.isEmpty) {
      showMightySnackBar(message: 'Please enter your username');
      return;
    }
    if (password.isEmpty) {
      showMightySnackBar(message: 'Please enter your password');
      return;
    }

    try {
      kLoginComplete(true);
      final token = await _getFcmToken();
      final dynamic rawResponse = await ApiHelper().postData('login', {
        'username': username,
        'password': password,
        'fcm_token': token,
      });
      final response = _asResponseMap(rawResponse);

      if (_isSuccessful(response)) {
        await _clearAccountScopedData();
        loginResponse.value = LoginResponse.fromJson(response);
        loginSuccessfull(false);
        accessToken.value = loginResponse.value!.data.token;
        await prefs.setString('loginEmail', username);
        await prefs.setString('loginPassword', password);
        if (loginResponse.value!.data.user.role == '4') {
          OperatorController operatorController = Get.find();
          operatorController.getOperatorContainerList();
          Get.offAll(() => const OperatorHomeScreen());
        } else {
          ContainerController containerController = Get.find();
          // containerDbHelper.truncateTable(containerTable);
          containerController.getContainerList(isRefresh: true);
          VehicleController vehicleController = Get.find();
          vehicleController.getVehicleList(isRefresh: true, tabIndex: 0);
          // vehicleController.getTerminalVehicleList();
          // vehicleController.getNewVehicleList();
          // vehicleController.getLoadedVehicleList();
          // vehicleController.getBookedVehicleList();
          // vehicleController.getShippedVehicleList();
          vehicleController.getDeliveredVehicleList();
          // vehicleController.getReleasedVehicleList();
          UserController userController = Get.find();
          userController.getAllUsersList();
          Get.offAll(() => const HomeScreen());
        }

        emailController.clear();
        passwordController.clear();
      } else {
        showMightySnackBar(
          message: _responseMessage(response),
        );
      }
    } catch (err) {
      showMightySnackBar(message: _friendlyError(err));
      debugPrint('Login failed: $err');
    } finally {
      kLoginComplete(false);
    }
  }

  Rx<LoginResponse?> loginResponse = Rx(null);

  Future<void> forgotPassword() async {
    final email = forgotPasswordEmailController.text.trim();
    if (email.isEmpty) {
      showMightySnackBar(message: 'Please enter your email address');
      return;
    }

    try {
      kForgotPasswordLoading(true);
      final dynamic rawResponse = await ApiHelper().postData(
        'forgot-password',
        {'email': email},
      );
      final response = _asResponseMap(rawResponse);

      if (_isSuccessful(response)) {
        kForgotPasswordSubmitted(true);
        showMightySnackBar(
          message: _responseMessage(
            response,
            fallback:
                'Password reset instructions have been sent to your email.',
          ),
          color: const Color(0xFF07845F),
        );
      } else {
        showMightySnackBar(
          message: _responseMessage(
            response,
            fallback: 'Unable to send reset instructions. Please try again.',
          ),
        );
      }
    } catch (err) {
      showMightySnackBar(message: _friendlyError(err));
      debugPrint('Forgot password failed: $err');
    } finally {
      kForgotPasswordLoading(false);
    }
  }

  login({required String email, required String password}) async {
    if (email.trim().isEmpty || password.isEmpty) {
      Get.offAll(() => const LoginScreen());
      return;
    }

    try {
      kLoginComplete(true);
      final token = await _getFcmToken();
      final dynamic rawResponse = await ApiHelper().postData('login', {
        'username': email.trim(),
        'password': password,
        'fcm_token': token,
      });
      final response = _asResponseMap(rawResponse);

      if (!_isSuccessful(response)) {
        Get.offAll(() => const LoginScreen());
        return;
      }

      await _clearAccountScopedData();
      loginResponse.value = LoginResponse.fromJson(response);
      if (loginResponse.value!.success) {
        loginSuccessfull(false);
        accessToken.value = loginResponse.value!.data.token;
        if (loginResponse.value!.data.user.role != null &&
            loginResponse.value!.data.user.role == "4") {
          OperatorController operatorController = Get.find();
          operatorController.getOperatorContainerList();
          Get.offAll(() => const OperatorHomeScreen());
        } else {
          VehicleController vehicleController = Get.find();
          vehicleController.getVehicleList(isRefresh: true, tabIndex: 0);
          // vehicleController.getTerminalVehicleList();
          // vehicleController.getNewVehicleList();
          // vehicleController.getLoadedVehicleList();
          // vehicleController.getBookedVehicleList();
          // vehicleController.getShippedVehicleList();
          vehicleController.getDeliveredVehicleList();
          // vehicleController.getReleasedVehicleList();
          ContainerController containerController = Get.find();
          // containerDbHelper.truncateTable(containerTable);
          containerController.getContainerList(isRefresh: true);
          UserController userController = Get.find();
          userController.getAllUsersList();

          Get.offAll(() => const HomeScreen());
        }
        await prefs.setString('loginEmail', email.trim());
        await prefs.setString('loginPassword', password);
      } else {
        // showMightySnackBar(message: 'Email and Password doesnot match');
        Get.offAll(() => const LoginScreen());
      }

      // showMightySnackBar(message: response['message']);
    } catch (e) {
      printError(info: e.toString());
      Get.offAll(() => const LoginScreen());
      // showMightySnackBar(message: e.toString());
    } finally {
      kLoginComplete(false);
    }
  }

  Future<String> _getFcmToken() async {
    try {
      return await FirebaseMessaging.instance.getToken() ?? '';
    } catch (error) {
      debugPrint('FCM token unavailable during login: $error');
      return '';
    }
  }

  Future<void> _clearAccountScopedData() async {
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().clearAccountData();
    }
    if (Get.isRegistered<VehicleController>()) {
      Get.find<VehicleController>().clearAccountData();
    }
    if (Get.isRegistered<ContainerController>()) {
      Get.find<ContainerController>().clearAccountData();
    }
    if (Get.isRegistered<UserController>()) {
      Get.find<UserController>().clearAccountData();
    }
    if (Get.isRegistered<OperatorController>()) {
      Get.find<OperatorController>().clearAccountData();
    }
    if (Get.isRegistered<TransactionController>()) {
      Get.find<TransactionController>().clearAccountData();
    }
    await _clearLocalAccountCache();
  }

  Future<void> _clearLocalAccountCache() async {
    try {
      for (final tableName in [
        terminalVehicleTable,
        newVehicleTable,
        bookedVehicleTable,
        loadedVehicleTable,
        shippedVehicleTable,
        deliveredVehicleTable,
        releasedClientVehicleTable,
      ]) {
        await vehicleDbHelper.truncateTable(tableName);
      }
      for (final tableName in [
        vehicleImageTable,
        terminalVehicleImageTable,
        newVehicleImageTable,
        bookedVehicleImageTable,
        loadedVehicleImageTable,
        shippedVehicleImageTable,
        deliveredVehicleImageTable,
        releasedVehicleImageTable,
      ]) {
        await vehicleImageDbHelper.truncateTable(tableName);
      }
      await containerDbHelper.truncateTable(containerTable);
    } catch (error) {
      debugPrint('Local account cache clear skipped: $error');
    }
  }

  Future<void> clearSessionAndAccountData() async {
    await _clearAccountScopedData();
    accessToken.value = '';
    loginResponse.value = null;
    loginSuccessfull(false);
  }

  Map<String, dynamic> _asResponseMap(dynamic response) {
    if (response is Map<String, dynamic>) {
      return response;
    }
    if (response is Map) {
      return Map<String, dynamic>.from(response);
    }
    throw MightyException(
      'The KG Auto server returned an unexpected response.',
    );
  }

  bool _isSuccessful(Map<String, dynamic> response) {
    final success = response['success'];
    return success == true || success == 1 || success == '1';
  }

  String _responseMessage(
    Map<String, dynamic> response, {
    String fallback = 'Username or password is incorrect.',
  }) {
    final message = response['message']?.toString().trim();
    if (message != null && message.isNotEmpty) {
      return message == 'Unauthorised.'
          ? 'Username or password is incorrect.'
          : message;
    }
    return fallback;
  }

  String _friendlyError(Object error) {
    if (error is MightyException) {
      return error.msg;
    }
    return 'Unable to sign in right now. Please try again.';
  }

  checkLoginStatus() async {
    try {
      prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('loginEmail')?.trim() ?? '';
      final password = prefs.getString('loginPassword') ?? '';

      if (email.isNotEmpty && password.isNotEmpty) {
        await login(email: email, password: password);
        return;
      }

      Timer(const Duration(seconds: 1), () {
        Get.offAll(() => const LoginScreen());
      });
    } catch (err) {
      debugPrint(err.toString());
    }
  }

  late VehicleDbHelper vehicleDbHelper;
  late ContainerDbHelper containerDbHelper;
  late VehicleImageDbHelper vehicleImageDbHelper;
  sharedInitialise() async {
    prefs = await SharedPreferences.getInstance();
    vehicleDbHelper = VehicleDbHelper();
    // vehicleDbHelper.truncateTable(terminalVehicleTable);
    // vehicleDbHelper.truncateTable(newVehicleTable);
    // vehicleDbHelper.truncateTable(bookedVehicleTable);
    // vehicleDbHelper.truncateTable(loadedVehicleTable);
    // vehicleDbHelper.truncateTable(shippedVehicleTable);
    // vehicleDbHelper.truncateTable(deliveredVehicleTable);
    // vehicleDbHelper.truncateTable(releasedClientVehicleTable);
    vehicleImageDbHelper = VehicleImageDbHelper();
    containerDbHelper = ContainerDbHelper();
    // containerDbHelper.truncateTable(containerTable);
    Db();
    Get.put(VehicleController());
    Get.put(ContainerController());
    Get.put(UserController());
  }
}
