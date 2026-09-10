class VehicleEmailHistory {
  VehicleEmailHistory({
    this.id,
    this.sentTo,
    this.createdAt,
  });

  final dynamic id;
  final dynamic sentTo;
  final dynamic createdAt;

  factory VehicleEmailHistory.fromJson(Map<String, dynamic> json) {
    return VehicleEmailHistory(
      id: json['id'],
      sentTo: json['sent_to'] ?? json['email'] ?? json['to'],
      createdAt: json['created_at'],
    );
  }
}
