import 'dart:async';
import 'dart:convert';

import 'package:cargo/controllers/auth_controller.dart';
import 'package:cargo/utils/global_helpers.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../models/countrie_code.dart';
import '../models/login_response.dart';
import '../models/sub_user_list_response.dart';
import '../ui/auth/login_screen.dart';
import '../utils/api_helper.dart';

class UserController extends GetxController {
  RxBool kIsLoading = false.obs;
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController oldPasswordController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController companyController = TextEditingController();

  RxString countryString = 'Choose Country'.obs;
  RxString phoneCodeString = ''.obs;

  RxBool kIsAddingUser = false.obs;
  addUser() async {
    try {
      if (usernameController.text.isEmpty) {
        showMightySnackBar(message: 'Please enter user name');
      } else {
        if (passwordController.text.isEmpty) {
          showMightySnackBar(message: 'Please enter user password');
        } else {
          if (!emailController.text.isEmail) {
            showMightySnackBar(message: 'Please enter valid email address');
          } else {
            kIsAddingUser(true);
            var moduleRes =
                await ApiHelper().postDataAuthenticated('add-sub-user', {
              'surname': usernameController.text,
              'name': nameController.text,
              'email': emailController.text,
              'password': passwordController.text,
              'country': countryString.value == 'Choose Country'
                  ? ''
                  : countryString.value,
              'phone':
                  phoneCodeString.value.isEmpty || phoneController.text.isEmpty
                      ? ''
                      : '${phoneCodeString.value} ${phoneController.text}',
              'company': companyController.text,
            });
            if (moduleRes['success']) {
              getAllUsersList();
              clearField();
              Get.back();
              showMightySnackBar(message: 'User Added Successfully');
            } else {
              showMightySnackBar(message: '${moduleRes['message']}');
            }
          }
        }
      }
    } catch (err) {
      debugPrint(err.toString());
    } finally {
      kIsAddingUser(false);
    }
  }

  RxString initialCountry = 'JO'.obs;
  Rx<AppUser?> selectedSubUser = Rx<AppUser?>(null);
  Rx<AppUser?> selectedOperatorUser = Rx<AppUser?>(null);

  void clearAccountData() {
    clearField();
    clearUserProfile();
    selectedSubUser.value = null;
    selectedOperatorUser.value = null;
    operatorUserList.clear();
    filterOperatorUserList.clear();
    subUserList.clear();
    filterSubUserList.clear();
    searchOnStoppedTyping.value?.cancel();
    searchStringController.clear();
  }

  populateUserData() {
    var dialCode = '';
    var newPhoneNumber = '';

    try {
      Map<String, String> foundedCountry = {};
      for (var country in CountriesCode.allCountries) {
        String dialCode = country["dial_code"].toString();
        if (selectedSubUser.value!.phone!.contains(dialCode)) {
          foundedCountry = country;
        }
      }

      if (foundedCountry.isNotEmpty) {
        var dialCode = selectedSubUser.value!.phone!.substring(
          0,
          foundedCountry["dial_code"]!.length,
        );
        var newPhoneNumber = selectedSubUser.value!.phone!.substring(
          foundedCountry["dial_code"]!.length,
        );
        initialCountry.value = dialCode;
        phoneCodeString.value = dialCode;
        phoneController.text = newPhoneNumber;
      }
    } catch (err) {
      debugPrint(err.toString());
      initialCountry.value = dialCode;
      phoneCodeString.value = dialCode;
      phoneController.text = newPhoneNumber;
    }
    usernameController.text = selectedSubUser.value!.surname ?? '';
    nameController.text = selectedSubUser.value!.name;
    countryString.value = selectedSubUser.value!.country == null
        ? 'Choose Country'
        : selectedSubUser.value!.country!;

    emailController.text = selectedSubUser.value!.email;
    companyController.text = selectedSubUser.value!.company ?? '';
  }

  clearField() {
    usernameController.clear();
    passwordController.clear();
    nameController.clear();
    oldPasswordController.clear();
    countryString.value = 'Choose Country';
    phoneCodeString.value = '';
    initialCountry.value = 'JO';
    phoneController.clear();
    emailController.clear();
    companyController.clear();
  }

  AuthController authController = Get.find();
  populateUserProfile() {
    usernameController.text =
        '${authController.loginResponse.value!.data.user.name}';
    passwordController.text = '';
    nameController.text =
        '${authController.loginResponse.value!.data.user.surname ?? ''}';
    phoneController.text =
        '${authController.loginResponse.value!.data.user.phone ?? ''}';
    emailController.text =
        '${authController.loginResponse.value!.data.user.email}';
    companyController.text =
        '${authController.loginResponse.value!.data.user.company ?? ''}';
  }

  clearUserProfile() {
    usernameController.clear();
    passwordController.clear();
    nameController.clear();
    phoneController.clear();
    emailController.clear();
    companyController.clear();
  }

  RxList<AppUser> operatorUserList = RxList();
  RxList<AppUser> filterOperatorUserList = RxList();
  Future<void> getAllOperatorUsersList() async {
    try {
      // kIsLoading.value = true;
      var moduleRes = await ApiHelper().getDataAuthenticated('users');

      SubUserListResponse vlr =
          subUserListResponseFromJson(jsonEncode(moduleRes));
      operatorUserList.clear();
      filterOperatorUserList.clear();
      operatorUserList.addAll(vlr.subUserList);
      filterOperatorUserList.addAll(vlr.subUserList);
      // kIsLoading.value = false;
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  RxList<AppUser> subUserList = RxList();
  RxList<AppUser> filterSubUserList = RxList();
  RxBool kDeletingSubUser = false.obs;
  Future<void> getAllUsersList() async {
    try {
      // kIsLoading.value = true;
      var moduleRes = await ApiHelper().getDataAuthenticated('sub-users');

      SubUserListResponse vlr =
          subUserListResponseFromJson(jsonEncode(moduleRes));
      subUserList.clear();
      filterSubUserList.clear();
      subUserList.addAll(vlr.subUserList);
      filterSubUserList.addAll(vlr.subUserList);
      // kIsLoading.value = false;
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  Future<bool> addUserToVehicle(dynamic userId, dynamic vehicleId) async {
    try {
      final moduleRes = await ApiHelper().postDataAuthenticated(
          'add-user-to-vehicle',
          {'user_id': '$userId', 'vehicle_id': '$vehicleId'});
      if (moduleRes['success'] == true) {
        Get.back();
        showMightySnackBar(message: 'Vehicle Added To User');
        return true;
      }
      showMightySnackBar(
        message: moduleRes['message']?.toString() ??
            moduleRes['error']?.toString() ??
            'Unable to assign user',
      );
      return false;
    } catch (err) {
      debugPrint(err.toString());
      showMightySnackBar(message: 'Unable to assign user');
      return false;
    }
  }

  Future<bool> removeUserFromVehicle(dynamic assignmentId) async {
    try {
      final moduleRes = await ApiHelper()
          .deleteDataAuthenticated('mobile/vehicle-sub-users/$assignmentId');
      if (moduleRes['success'] == true) {
        showMightySnackBar(message: 'Assigned user removed successfully');
        return true;
      }
      showMightySnackBar(
        message: moduleRes['message']?.toString() ?? 'Unable to remove user',
      );
      return false;
    } catch (error) {
      debugPrint(error.toString());
      showMightySnackBar(message: 'Unable to remove assigned user');
      return false;
    }
  }

  Future<bool> deleteSubUser(AppUser user) async {
    try {
      kDeletingSubUser(true);
      final moduleRes = await ApiHelper()
          .deleteDataAuthenticated('mobile/sub-users/${user.id}');
      if (moduleRes['success'] == true) {
        subUserList.removeWhere((item) => item.id == user.id);
        filterSubUserList.removeWhere((item) => item.id == user.id);
        showMightySnackBar(message: 'Sub-user deleted successfully');
        return true;
      }
      showMightySnackBar(
        message: moduleRes['message']?.toString() ?? 'Unable to delete user',
      );
      return false;
    } catch (error) {
      debugPrint(error.toString());
      showMightySnackBar(message: 'Unable to delete sub-user');
      return false;
    } finally {
      kDeletingSubUser(false);
    }
  }

  TextEditingController searchStringController = TextEditingController();
  searchByUserName() {
    if (searchStringController.text.isEmpty) {
      filterSubUserList.clear();
      filterSubUserList.addAll(subUserList);
    } else {
      filterSubUserList.clear();
      for (final element in subUserList) {
        if (element.name
            .toUpperCase()
            .contains(searchStringController.text.toUpperCase())) {
          filterSubUserList.add(element);
        }
      }
      filterSubUserList.refresh();
    }
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
        filterSubUserList.clear();
        for (final element in subUserList) {
          if (element.name
              .toUpperCase()
              .contains(searchStringController.text.toUpperCase())) {
            filterSubUserList.add(element);
          }
        }
        filterSubUserList.refresh();
      });
    } else {
      searchOnStoppedTyping.value = Timer(duration, () async {
        filterSubUserList.clear();
        filterSubUserList.addAll(subUserList);
      });
    }
  }

  signout() async {
    try {
      await ApiHelper().getDataAuthenticated(
          'logout/${authController.loginResponse.value!.data.user.id}');
      _clearLoginSession();
      await authController.clearSessionAndAccountData();
      Get.offAll(() => const LoginScreen());
    } catch (err) {
      _clearLoginSession();
      await authController.clearSessionAndAccountData();
      Get.offAll(() => const LoginScreen());
      debugPrint(err.toString());
    }
  }

  void _clearLoginSession() {
    authController.prefs.remove('loginEmail');
    authController.prefs.remove('loginPassword');
  }

  RxBool kUpdateProfileInfo = false.obs;

  updateUserInfo() async {
    try {
      kUpdateProfileInfo(true);
      final newPassword = passwordController.text;
      if (newPassword.isNotEmpty) {
        final currentPasswordVerified = await _verifyCurrentPassword();
        if (!currentPasswordVerified) return;
      }
      var moduleRes = await ApiHelper().postDataAuthenticated(
          'update-user-info/${authController.loginResponse.value!.data.user.id}',
          {
            'surname': nameController.text,
            'name': usernameController.text,
            'email': emailController.text,
            'password': newPassword,
            'country': countryString.value == 'Choose Country'
                ? ''
                : countryString.value,
            'phone':
                phoneCodeString.value.isEmpty || phoneController.text.isEmpty
                    ? ''
                    : '${phoneCodeString.value} ${phoneController.text}',
            'company': companyController.text,
            'old_password': oldPasswordController.text,
          });
      if (moduleRes['success']) {
        if (usernameController.text.isNotEmpty) {
          authController.prefs.setString('loginEmail', usernameController.text);
        }
        if (passwordController.text.isNotEmpty) {
          authController.prefs
              .setString('loginPassword', passwordController.text);
        }
        oldPasswordController.clear();
        passwordController.clear();
        showMightySnackBar(message: 'Profile Updated Successfully');
        authController.checkLoginStatus();
      } else {
        showMightySnackBar(message: '${moduleRes['message']}');
      }
    } catch (err) {
      debugPrint(err.toString());
    } finally {
      kUpdateProfileInfo(false);
    }
  }

  Future<bool> _verifyCurrentPassword() async {
    final currentPassword = oldPasswordController.text;
    if (currentPassword.isEmpty) {
      showMightySnackBar(message: 'Please enter your current password');
      return false;
    }

    final loginUsername = authController.prefs.getString('loginEmail') ??
        authController.loginResponse.value?.data.user.email ??
        emailController.text;
    if (loginUsername.toString().trim().isEmpty) {
      showMightySnackBar(message: 'Unable to verify current password');
      return false;
    }

    try {
      final token = await FirebaseMessaging.instance.getToken() ?? '';
      final response = await ApiHelper().postData('login', {
        'username': loginUsername.toString().trim(),
        'password': currentPassword,
        'fcm_token': token,
      });
      final success = response is Map ? response['success'] : null;
      if (success == true || success == 1 || success == '1') {
        return true;
      }
      showMightySnackBar(message: 'Current password is incorrect');
      return false;
    } catch (err) {
      debugPrint(err.toString());
      showMightySnackBar(message: 'Current password is incorrect');
      return false;
    }
  }
}
