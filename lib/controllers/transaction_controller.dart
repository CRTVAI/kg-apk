import 'dart:convert';

import 'package:cargo/controllers/auth_controller.dart';
import 'package:cargo/utils/global_helpers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../models/financial_login_response.dart';
import '../models/transaction_response.dart';
import '../ui/transactions/transactions_screen.dart';
import '../utils/api_helper.dart';

class TransactionController extends GetxController {
  RxBool kIsLoading = false.obs;
  Rx<TransactionResponse?> transactionResponse = Rx<TransactionResponse?>(null);
  AuthController authController = Get.find();
  RxList<TransactionHistory> historyList = RxList();
  RxList<TransactionHistory> filterHistoryList = RxList();
  RxBool kIsPasswordPassed = false.obs;
  TextEditingController passwordController = TextEditingController();
  RxBool kIsPasswordVisible = false.obs;
  RxBool kIsPasswordChecking = false.obs;

  checkPassword() async {
    try {
      kIsPasswordChecking(true);
      var moduleRes =
          await ApiHelper().postDataAuthenticated('financial-login', {
        'password': passwordController.text,
      });
      print(moduleRes);
      FinancialLoginResponse financialLoginResponse =
          financialLoginResponseFromJson(jsonEncode(moduleRes));
      if (financialLoginResponse.success != null &&
          financialLoginResponse.success) {
        kIsPasswordPassed(true);
        passwordController.clear();
      } else {
        kIsPasswordPassed(false);
        showMightySnackBar(message: 'Wrong Password');
      }
      // var prefs = await SharedPreferences.getInstance();
      // String password = prefs.getString('loginPassword')??'';
      // if(password==passwordController.text){
      //   kIsPasswordPassed(true);
      //   passwordController.clear();
      // }else{
      //   kIsPasswordPassed(false);
      //   showMightySnackBar(message: 'Wrong Password');
      // }
    } catch (err) {
      print(err.toString());
    } finally {
      kIsPasswordChecking(false);
    }
  }

  RxList<SalesData> paymentData = RxList();
  RxInt indexNo = 1.obs;

  RxBool kLoadingData = false.obs;

  void clearAccountData() {
    transactionResponse.value = null;
    historyList.clear();
    filterHistoryList.clear();
    paymentData.clear();
    kIsPasswordPassed(false);
    passwordController.clear();
    kIsPasswordVisible(false);
    kIsPasswordChecking(false);
    indexNo.value = 1;
    kLoadingData(false);
  }

  Future<void> getTransactionData({bool? isRefresh, bool? firstTime}) async {
    try {
      kLoadingData(true);
      if (isRefresh!) {
        indexNo.value = 1;
      }

      var moduleRes = await ApiHelper().getDataAuthenticated(
          'financial-data/${authController.loginResponse.value!.data.user.id}?PageIndex=${indexNo.value}');
      TransactionResponse vlr =
          transactionResponseFromJson(jsonEncode(moduleRes));
      transactionResponse.value = vlr;
      paymentData.clear();
      if (firstTime != null && firstTime) {
        kIsLoading(true);
        var dp = vlr.transactionData!.duePayments;
        var dpl = vlr.transactionData!.duePaymentsLimit;

        if (dp > dpl) {
          // paymentData.add(SalesData('2023', 100, HexColor('#F9D46C')));
          paymentData.add(SalesData('${DateTime.now().year}',
              vlr.transactionData!.duePaymentsLimit, HexColor('#F3F3F3')));
          // paymentData.add(SalesData('2023', 1500, HexColor('#F3F3F3')));
          paymentData.add(SalesData('${DateTime.now().year}',
              vlr.transactionData!.duePayments, HexColor('#F9D46C')));
        } else {
          // paymentData.add(SalesData('2023', 100, HexColor('#F9D46C')));
          paymentData.add(SalesData('${DateTime.now().year}',
              vlr.transactionData!.duePayments, HexColor('#F9D46C')));
          // paymentData.add(SalesData('2023', 1500, HexColor('#F3F3F3')));
          paymentData.add(SalesData('${DateTime.now().year}',
              vlr.transactionData!.duePaymentsLimit, HexColor('#F3F3F3')));
        }
        kIsLoading(false);
      }

      if (isRefresh) {
        historyList.clear();
        filterHistoryList.clear();
        historyList.addAll(vlr.transactionData!.transactionHistory);
        filterHistoryList.addAll(vlr.transactionData!.transactionHistory);
      } else {
        historyList.addAll(vlr.transactionData!.transactionHistory);
        filterHistoryList.addAll(vlr.transactionData!.transactionHistory);

        historyList.refresh();
        filterHistoryList.refresh();
      }

      indexNo.value += 1;
      indexNo.refresh();
    } catch (error) {
      debugPrint(error.toString());
    } finally {
      kLoadingData(false);
    }
  }

  refreshTransactionData(RefreshController refreshController) async {
    await getTransactionData(isRefresh: true, firstTime: false);
    if (kLoadingData.isTrue) {
      refreshController.requestLoading();
    } else {
      refreshController.refreshCompleted();
    }
  }

  loadMoreTransactionData(RefreshController refreshController) async {
    try {
      await getTransactionData(isRefresh: false, firstTime: false);
      if (kLoadingData.isTrue) {
        refreshController.requestLoading();
      } else {
        refreshController.loadComplete();
      }
    } catch (err) {
      debugPrint(err.toString());
    }
  }

  //
  // getTransactionData()async
  // {
  //   try{
  //     kIsLoading(true);
  //     var moduleRes = await ApiHelper().getDataAuthenticated('financial-data/${authController.loginResponse.value!.data.user.id}');
  //
  //     TransactionResponse vlr = transactionResponseFromJson(jsonEncode(moduleRes));
  //     transactionResponse.value = vlr;
  //     var dp = vlr.transactionData.duePayments;
  //     var dpl = vlr.transactionData.duePaymentsLimit;
  //
  //     if(dp>dpl){
  //       // paymentData.add(SalesData('2023', 100, HexColor('#F9D46C')));
  //       paymentData.add(SalesData('2023', vlr.transactionData.duePaymentsLimit, HexColor('#F9D46C')));
  //       // paymentData.add(SalesData('2023', 1500, HexColor('#F3F3F3')));
  //       paymentData.add(SalesData('2023', vlr.transactionData.duePayments, HexColor('#F3F3F3')));
  //     }else{
  //       // paymentData.add(SalesData('2023', 100, HexColor('#F9D46C')));
  //       paymentData.add(SalesData('2023', vlr.transactionData.duePayments, HexColor('#F9D46C')));
  //       // paymentData.add(SalesData('2023', 1500, HexColor('#F3F3F3')));
  //       paymentData.add(SalesData('2023', vlr.transactionData.duePaymentsLimit, HexColor('#F3F3F3')));
  //     }
  //
  //     historyList.clear();
  //     filterHistoryList.clear();
  //     historyList.addAll(vlr.transactionData.transactionHistory);
  //     filterHistoryList.addAll(vlr.transactionData.transactionHistory);
  //   }catch(err){
  //     print(err.toString());
  //   }finally{
  //     kIsLoading(false);
  //   }
  // }

  // filterTransaction(String query){
  //   if(query=='Paid'){
  //     filterHistoryList.clear();
  //     historyList.forEach((element) {
  //       if(element.status.toLowerCase()=='paid'){
  //         filterHistoryList.add(element);
  //       }
  //     });
  //   }else if(query=='Unpaid'){
  //     filterHistoryList.clear();
  //     historyList.forEach((element) {
  //       if(element.status.toLowerCase()=='unpaid'){
  //         filterHistoryList.add(element);
  //       }
  //     });
  //   }else{
  //     filterHistoryList.clear();
  //     filterHistoryList.addAll(historyList);
  //   }
  //
  // }
}
