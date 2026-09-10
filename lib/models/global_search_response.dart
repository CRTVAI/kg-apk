import 'container_list_response.dart';
import 'pickup_request_response.dart';
import 'vehicle_list_response.dart';

class GlobalSearchResults {
  GlobalSearchResults({
    required this.vehicles,
    required this.containers,
    required this.pickupRequests,
  });

  final List<VehicleList> vehicles;
  final List<Containers> containers;
  final List<PickupRequest> pickupRequests;

  bool get isEmpty =>
      vehicles.isEmpty && containers.isEmpty && pickupRequests.isEmpty;

  int get totalCount =>
      vehicles.length + containers.length + pickupRequests.length;

  factory GlobalSearchResults.empty() {
    return GlobalSearchResults(
      vehicles: <VehicleList>[],
      containers: <Containers>[],
      pickupRequests: <PickupRequest>[],
    );
  }

  factory GlobalSearchResults.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : <String, dynamic>{};

    return GlobalSearchResults(
      vehicles: _parseList(data['vehicles'], VehicleList.fromJson),
      containers: _parseList(data['containers'], Containers.fromJson),
      pickupRequests: _parseList(
        data['pickup_requests'] ?? data['pick_history'],
        PickupRequest.fromJson,
      ),
    );
  }
}

List<T> _parseList<T>(
  dynamic value,
  T Function(Map<String, dynamic> json) builder,
) {
  if (value is! List) return <T>[];

  return value
      .whereType<Map>()
      .map((item) => builder(Map<String, dynamic>.from(item)))
      .toList();
}
