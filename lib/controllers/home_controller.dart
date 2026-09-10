import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/announcement_response.dart';
import '../models/global_search_response.dart';
import '../utils/api_helper.dart';
import '../utils/global_helpers.dart';

class HomeController extends GetxController {
  RxBool kIsLoading = false.obs;
  RxBool kGlobalSearchLoading = false.obs;
  RxBool kAnnouncementsLoading = false.obs;
  RxInt kSelectedIndex = 0.obs;
  RxInt selectedIndex = 2.obs;
  RxBool kShipmentOverviewLoading = false.obs;
  RxInt terminalOverviewCount = 0.obs;
  RxInt shippedOverviewCount = 0.obs;
  RxInt deliveredOverviewCount = 0.obs;
  TextEditingController globalSearchController = TextEditingController();
  Rx<GlobalSearchResults> globalSearchResults = GlobalSearchResults.empty().obs;
  RxList<AnnouncementItem> announcements = RxList<AnnouncementItem>();

  void clearAccountData() {
    kSelectedIndex.value = 0;
    selectedIndex.value = 2;
    terminalOverviewCount.value = 0;
    shippedOverviewCount.value = 0;
    deliveredOverviewCount.value = 0;
    globalSearchController.clear();
    globalSearchResults.value = GlobalSearchResults.empty();
    announcements.clear();
  }

  onItemTapped(int index) {
    kSelectedIndex.value = index;
  }

  Future<void> globalSearch() async {
    final query = globalSearchController.text.trim();
    if (query.length < 2) {
      globalSearchResults.value = GlobalSearchResults.empty();
      return;
    }

    try {
      kGlobalSearchLoading(true);
      final response = await ApiHelper().getDataAuthenticated(
        'mobile/global-search?query=${Uri.encodeQueryComponent(query)}',
      );
      globalSearchResults.value = GlobalSearchResults.fromJson(
        Map<String, dynamic>.from(response),
      );
    } catch (error) {
      globalSearchResults.value = GlobalSearchResults.empty();
      showMightySnackBar(message: 'Unable to search right now.');
      debugPrint('Global search failed: $error');
    } finally {
      kGlobalSearchLoading(false);
    }
  }

  Future<void> getAnnouncements() async {
    try {
      kAnnouncementsLoading(true);
      final response = await ApiHelper().getDataAuthenticated(
        'mobile/announcements',
      );
      final data = response is Map ? response['data'] : null;
      announcements.assignAll(
        data is List
            ? data
                .whereType<Map>()
                .map((item) =>
                    AnnouncementItem.fromJson(Map<String, dynamic>.from(item)))
                .toList()
            : <AnnouncementItem>[],
      );
    } catch (error) {
      debugPrint('Announcements failed: $error');
    } finally {
      kAnnouncementsLoading(false);
    }
  }

  Future<void> loadShipmentOverview() async {
    try {
      kShipmentOverviewLoading(true);
      final response = await ApiHelper().getDataAuthenticated(
        'mobile/shipment-overview',
      );
      final data = response is Map ? response['data'] ?? response : null;
      if (data is! Map) return;

      final terminal = _countFromSummary(data, [
        'at_terminal',
        'terminal',
        'atTerminal',
        'at_terminal_count',
        'terminal_count',
      ]);
      final shipped = _countFromSummary(data, [
        'shipped',
        'shipped_count',
      ]);
      final delivered = _countFromSummary(data, [
        'delivered',
        'delivered_count',
      ]);

      if (terminal != null) terminalOverviewCount.value = terminal;
      if (shipped != null) shippedOverviewCount.value = shipped;
      if (delivered != null) deliveredOverviewCount.value = delivered;
    } catch (error) {
      debugPrint('Shipment overview failed: $error');
    } finally {
      kShipmentOverviewLoading(false);
    }
  }

  int? _countFromSummary(Map data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value is int) return value;
      if (value is num) return value.toInt();
      final parsed = int.tryParse(value?.toString() ?? '');
      if (parsed != null) return parsed;
    }
    return null;
  }

  Future<void> markAnnouncementAsRead(AnnouncementItem item) async {
    try {
      await ApiHelper().postDataAuthenticated(
        'mobile/announcements/mark-as-read/${item.id}',
      );
      announcements.removeWhere((announcement) => announcement.id == item.id);
    } catch (error) {
      showMightySnackBar(message: 'Unable to mark announcement as read.');
      debugPrint('Mark announcement failed: $error');
    }
  }
}
