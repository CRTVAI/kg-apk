import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../config/config.dart';
import '../controllers/auth_controller.dart';
import 'global_helpers.dart';
import 'mighty_exception.dart';

class ApiHelper {
  static const Duration _requestTimeout = Duration(seconds: 25);

  Future<dynamic> postData(
    String url, [
    Map<String, dynamic> data = const {},
  ]) async {
    try {
      final String finalUrl = kcBaseAPIUrl + url;
      final res = await http.post(
        Uri.parse(finalUrl),
        body: data,
        headers: const {'accept': 'application/json'},
      ).timeout(_requestTimeout);
      return _decodeResponse(res, finalUrl);
    } on TimeoutException {
      throw MightyException(
        'The KG Auto server took too long to respond. Please try again.',
      );
    } on SocketException {
      throw MightyException(
        'Unable to reach the KG Auto server. Check your internet connection.',
      );
    } on http.ClientException {
      throw MightyException(
        'Unable to connect securely to the KG Auto server.',
      );
    }
  }

  Future<dynamic> getData(
    String url, [
    Map<String, dynamic> data = const {},
  ]) async {
    try {
      final String finalUrl = kcBaseAPIUrl + url;
      final res = await http.get(
        Uri.parse(finalUrl),
        headers: const {'accept': 'application/json'},
      ).timeout(_requestTimeout);
      final body = _decodeResponse(res, finalUrl);
      if (res.statusCode < 200 || res.statusCode >= 300) {
        throw MightyException(_messageFrom(body) ?? 'The request failed.');
      }
      return body;
    } on TimeoutException {
      throw MightyException(
        'The KG Auto server took too long to respond. Please try again.',
      );
    } on SocketException {
      throw MightyException(
        'Unable to reach the KG Auto server. Check your internet connection.',
      );
    } on http.ClientException {
      throw MightyException(
        'Unable to connect securely to the KG Auto server.',
      );
    }
  }

  Future<dynamic> getDataAuthenticated(
    String url, [
    Map<String, dynamic> data = const {},
  ]) async {
    try {
      AuthController authController = Get.find();
      final String finalUrl = kcBaseAPIUrl + url;
      final res = await http.get(
        Uri.parse(finalUrl),
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer ${authController.accessToken.value}',
        },
      ).timeout(_requestTimeout);
      final body = _decodeResponse(res, finalUrl);
      if (res.statusCode < 200 || res.statusCode >= 300) {
        throw MightyException(
          _messageFrom(body) ?? 'The request could not be completed.',
        );
      }
      return body;
    } on TimeoutException {
      throw MightyException(
        'The KG Auto server took too long to respond. Please try again.',
      );
    } on SocketException {
      throw MightyException(
        'Unable to reach the KG Auto server. Check your internet connection.',
      );
    } on http.ClientException {
      throw MightyException(
        'Unable to connect securely to the KG Auto server.',
      );
    }
  }

  Future<dynamic> postDataAuthenticated(
    String url, [
    Map<String, dynamic> data = const {},
  ]) async {
    try {
      final String finalUrl = kcBaseAPIUrl + url;
      AuthController authController = Get.find();
      final res = await http.post(
        Uri.parse(finalUrl),
        body: data,
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer ${authController.accessToken.value}',
        },
      ).timeout(_requestTimeout);
      return _decodeResponse(res, finalUrl);
    } on TimeoutException {
      throw MightyException(
        'The KG Auto server took too long to respond. Please try again.',
      );
    } on SocketException {
      throw MightyException(
        'Unable to reach the KG Auto server. Check your internet connection.',
      );
    } on http.ClientException {
      throw MightyException(
        'Unable to connect securely to the KG Auto server.',
      );
    }
  }

  Future<dynamic> deleteDataAuthenticated(String url) async {
    try {
      final String finalUrl = kcBaseAPIUrl + url;
      AuthController authController = Get.find();
      final res = await http.delete(
        Uri.parse(finalUrl),
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer ${authController.accessToken.value}',
        },
      ).timeout(_requestTimeout);
      final body = _decodeResponse(res, finalUrl);
      if (res.statusCode < 200 || res.statusCode >= 300) {
        throw MightyException(
          _messageFrom(body) ?? 'The request could not be completed.',
        );
      }
      return body;
    } on TimeoutException {
      throw MightyException(
        'The KG Auto server took too long to respond. Please try again.',
      );
    } on SocketException {
      throw MightyException(
        'Unable to reach the KG Auto server. Check your internet connection.',
      );
    } on http.ClientException {
      throw MightyException(
        'Unable to connect securely to the KG Auto server.',
      );
    }
  }

  dynamic _decodeResponse(http.Response response, String url) {
    final rawBody = response.body.trim();
    if (rawBody.isEmpty) {
      throw MightyException(
        'The KG Auto server returned an empty response '
        '(HTTP ${response.statusCode}).',
      );
    }

    dynamic body;
    try {
      body = jsonDecode(rawBody);
    } on FormatException {
      throw MightyException(
        'The KG Auto server returned an invalid response. Please try again.',
      );
    }

    if (kDebugMode) {
      printApiResponse(
        'API :: $url :: HTTP ${response.statusCode} :: '
        '${body is Map ? _messageFrom(body) ?? 'response received' : 'response received'}',
      );
    }

    if (response.statusCode >= 500) {
      throw MightyException(
        _messageFrom(body) ?? 'The KG Auto server is temporarily unavailable.',
      );
    }

    return body;
  }

  String? _messageFrom(dynamic body) {
    if (body is Map) {
      final message = body['message'];
      if (message != null && message.toString().trim().isNotEmpty) {
        return message.toString().trim();
      }
    }
    return null;
  }
}
