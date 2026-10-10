// To parse this JSON data, do
//
//     final containerListResponse = containerListResponseFromJson(jsonString);

import 'dart:convert';

import 'package:cargo/models/login_response.dart';
import 'package:cargo/models/vehicle_list_response.dart';

ContainerListResponse containerListResponseFromJson(String str) =>
    ContainerListResponse.fromJson(json.decode(str));
Containers notificationContainerResponseFromJson(String str) =>
    Containers.fromJson(json.decode(str));
String containerListResponseToJson(ContainerListResponse data) =>
    json.encode(data.toJson());

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  final text = value.toString();
  if (text.isEmpty || text == '0000-00-00') return null;
  return DateTime.tryParse(text);
}

class ContainerListResponse {
  dynamic success;
  List<Containers> containerList;
  dynamic message;

  ContainerListResponse({
    required this.success,
    required this.containerList,
    required this.message,
  });

  factory ContainerListResponse.fromJson(Map<String, dynamic> json) =>
      ContainerListResponse(
        success: json["success"],
        containerList: List<Containers>.from(
            json["data"].map((x) => Containers.fromJson(x))),
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "data": List<dynamic>.from(containerList.map((x) => x.toJson())),
        "message": message,
      };
}

class Containers {
  int id;
  dynamic statusId;
  dynamic shipperId;
  dynamic shippingLineId;
  dynamic consigneeId;
  dynamic preCarriageId;
  dynamic loadingPortId;
  dynamic dischargePortId;
  dynamic destinationPortId;
  dynamic vesselName;
  // dynamic notifyPartId;
  dynamic bookingNo;
  dynamic containerNo;
  // dynamic cutOff;
  dynamic departure;
  dynamic arrival;
  dynamic pierTerminalId;
  dynamic contractNo;
  // dynamic voyageNo;
  // dynamic sealNo;
  // dynamic exportReference;
  // dynamic domesticRouting;
  dynamic requestType;
  dynamic dateCreated;
  dynamic allPaid;
  // dynamic fowardingAgentId;
  // String? vgm;
  // String? notesDocument;

  List<VehicleElement>? vehicles;
  List<VehicleElement>? containerVehicles;
  List<dynamic>? containerImages;
  List<ContainerDocument>? containerDocuments;
  LoadingPort? status;
  Consignee? shipper;
  LoadingPort? shippingLine;
  Consignee? consignee;
  dynamic preCarriage;
  LoadingPort? loadingPort;
  LoadingPort? dischargePort;
  LoadingPort? destinationPort;
  LoadingPort? notifyParty;
  dynamic pierTerminal;
  LoadingPort? measurement;
  dynamic statusName;
  dynamic shippingLineName;
  dynamic consigneeName;
  dynamic consigneeAddress;
  dynamic loadingPortName;
  dynamic dischargePortName;
  dynamic destinationPortName;

  Containers(
      {required this.id,
      this.statusId,
      this.shipperId,
      this.shippingLineId,
      this.consigneeId,
      this.preCarriageId,
      this.vesselName,
      this.loadingPortId,
      this.dischargePortId,
      this.destinationPortId,
      // this.notifyPartId,
      this.bookingNo,
      this.containerNo,
      // this.cutOff,
      this.departure,
      this.arrival,
      this.pierTerminalId,
      this.contractNo,
      // this.voyageNo,
      // this.sealNo,
      // this.exportReference,
      // this.domesticRouting,
      // this.measurementId,
      // this.aesNrXtn,
      // this.aesNrItn,
      // this.invoiceDate,
      // this.invoiceTerm,
      // this.dateForLetter,
      // this.draft,
      // this.ownerId,
      // this.arrivalYm,
      this.requestType,
      this.dateCreated,
      // this.searchBody,
      // this.aesBlockBody,
      this.allPaid,
      // this.fowardingAgentId,
      // this.vgm,
      // this.notesDocument,
      this.vehicles,
      this.containerVehicles,
      this.containerImages,
      this.containerDocuments,
      this.status,
      this.shipper,
      this.shippingLine,
      this.consignee,
      this.preCarriage,
      this.loadingPort,
      this.dischargePort,
      this.destinationPort,
      this.notifyParty,
      this.pierTerminal,
      this.measurement,
      this.statusName,
      this.loadingPortName,
      this.dischargePortName,
      this.consigneeName,
      this.consigneeAddress,
      this.shippingLineName,
      this.destinationPortName});

  factory Containers.fromJson(Map<String, dynamic> json) => Containers(
        id: json["id"],
        statusId: json["status_id"],
        shipperId: json["shipper_id"],
        shippingLineId: json["shipping_line_id"],
        consigneeId: json["consignee_id"],
        preCarriageId: json["pre_carriage_id"],
        vesselName: json["vessel_name"],
        loadingPortId: json["loading_port_id"],
        dischargePortId: json["discharge_port_id"],
        destinationPortId: json["destination_port_id"],
        // notifyPartId: json["notify_part_id"],
        bookingNo: json["booking_no"],
        containerNo: json["container_no"],
        // cutOff: json["cut_off"],
        departure: _parseDate(json["departure"]),
        arrival: _parseDate(json["arrival"]),
        pierTerminalId: json["pier_terminal_id"],
        contractNo: json["contract_no"],
        // voyageNo: json["voyage_no"],
        // sealNo: json["seal_no"],
        // exportReference:json["export_reference"],
        // domesticRouting: json["domestic_routing"],
        // measurementId: json["measurement_id"],
        // aesNrXtn: json["aes_nr_xtn"],
        // aesNrItn: json["aes_nr_itn"],
        // invoiceDate:json["invoice_date"],
        // invoiceTerm: json["invoice_term"],
        // dateForLetter: json["date_for_letter"]==null?null:DateTime.parse(json["date_for_letter"]),
        // draft: json["draft"],
        // ownerId: json["owner_id"],
        // arrivalYm: json["arrival_ym"],
        requestType: json["request_type"],
        dateCreated: json["date_created"],
        // searchBody: json["search_body"],
        // aesBlockBody: json["aes_block_body"],
        allPaid: json["all_paid"],
        // fowardingAgentId: json["fowarding_agent_id"],
        // vgm: json["vgm"],
        // notesDocument: json["notes_document"],
        containerImages: json["container_images"] == null
            ? []
            : List<dynamic>.from(json["container_images"].map((x) => x)),
        containerDocuments: json["container_documents"] == null
            ? []
            : List<ContainerDocument>.from(json["container_documents"]
                .map((x) => ContainerDocument.fromJson(x))),
        // vehicles: List<VehicleElement>.from(json["vehicles"].map((x) => VehicleElement.fromJson(x))),
        vehicles: json["vehicles"] == null
            ? []
            : List<VehicleElement>.from(
                json["vehicles"].map((x) => VehicleElement.fromJson(x))),
        containerVehicles: json["container_vehicle"] == null
            ? []
            : List<VehicleElement>.from(json["container_vehicle"]
                .map((x) => VehicleElement.fromJson(x))),
        status: json["status"] == null
            ? null
            : LoadingPort.fromJson(json["status"]),
        shipper: json["shipper"] == null
            ? null
            : Consignee.fromJson(json["shipper"]),
        shippingLine: json["shipping_line"] == null
            ? null
            : LoadingPort.fromJson(json["shipping_line"]),
        consignee: json["consignee"] == null
            ? null
            : Consignee.fromJson(json["consignee"]),
        preCarriage: json["pre_carriage"],
        loadingPort: json["loading_port"] == null
            ? null
            : LoadingPort.fromJson(json["loading_port"]),
        dischargePort: json["discharge_port"] == null
            ? null
            : LoadingPort.fromJson(json["discharge_port"]),
        destinationPort: json["destination_port"] == null
            ? null
            : LoadingPort.fromJson(json["destination_port"]),
        notifyParty: json["notify_party"] == null
            ? null
            : LoadingPort.fromJson(json["notify_party"]),
        pierTerminal: json["pier_terminal"],
        measurement: json["measurement"] == null
            ? null
            : LoadingPort.fromJson(json["measurement"]),
        statusName: json["status_name"],
        shippingLineName: json["shipping_line_name"],
        consigneeName: json["consignee_name"],
        consigneeAddress: json["consignee_address"],
        loadingPortName: json["loading_port_name"],
        dischargePortName: json["discharge_port_name"],
        destinationPortName: json["destination_port_name"],
      );

  factory Containers.fromMap(Map<dynamic, dynamic> json) => Containers(
        id: json["id"],
        statusId: json["status_id"],
        shipperId: json["shipper_id"],
        shippingLineId: json["shipping_line_id"],
        bookingNo: json["booking_no"],
        containerNo: json["container_no"],
        statusName: json["status_name"],
        shippingLineName: json["shipping_line_name"],
        consigneeName: json["consignee_name"],
        consigneeAddress: json["consignee_address"],
        loadingPortName: json["loading_port_name"],
        dischargePortName: json["discharge_port_name"],
        destinationPortName: json["destination_port_name"],
        departure: json["departure"],
        arrival: json["arrival"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "status_id": statusId,
        "shipper_id": shipperId,
        "shipping_line_id": shippingLineId,
        "consignee_id": consigneeId,
        "pre_carriage_id": preCarriageId,
        "vessel_name": vesselName,
        "loading_port_id": loadingPortId,
        "discharge_port_id": dischargePortId,
        "destination_port_id": destinationPortId,
        // "notify_part_id": notifyPartId,
        "booking_no": bookingNo,
        "container_no": containerNo,
        // "cut_off": cutOff,
        "departure": departure,
        "arrival": arrival,
        "pier_terminal_id": pierTerminalId,
        "contract_no": contractNo,
        // "voyage_no": voyageNo,
        // "seal_no": sealNo,
        // "export_reference": exportReference,
        // "domestic_routing": domesticRouting,
        // "measurement_id": measurementId,
        // "aes_nr_xtn": aesNrXtn,
        // "aes_nr_itn": aesNrItn,
        // "invoice_date": invoiceDate,
        // "invoice_term": invoiceTerm,
        // "date_for_letter": dateForLetter,
        // "draft": draft,
        // "owner_id": ownerId,
        // "arrival_ym": arrivalYm,
        "request_type": requestType,
        "date_created": dateCreated,
        // "search_body": searchBody,
        // "aes_block_body": aesBlockBody,
        "all_paid": allPaid,
        // "fowarding_agent_id": fowardingAgentId,
        // "vgm": vgm,
        // "notes_document": notesDocument,

        "vehicles": List<dynamic>.from(vehicles!.map((x) => x.toJson())),
        "container_vehicle":
            List<dynamic>.from(containerVehicles!.map((x) => x.toJson())),
        "container_images": List<dynamic>.from(containerImages!.map((x) => x)),
        "container_documents":
            List<dynamic>.from(containerDocuments!.map((x) => x.toJson())),
        "status": status?.toJson(),
        "shipper": shipper?.toJson(),
        "shipping_line": shippingLine?.toJson(),
        "consignee": consignee?.toJson(),
        "pre_carriage": preCarriage,
        "loading_port": loadingPort?.toJson(),
        "discharge_port": dischargePort?.toJson(),
        "destination_port": destinationPort?.toJson(),
        "notify_party": notifyParty?.toJson(),
        "pier_terminal": pierTerminal,
        "measurement": measurement?.toJson(),
      };

  Map<String, dynamic> toMap() => {
        "id": id,
        "status_id": statusId,
        "shipper_id": shipperId,
        "shipping_line_id": shippingLineId,
        "booking_no": bookingNo,
        "container_no": containerNo,
        "status_name": statusName,
        "shipping_line_name": shippingLineName,
        "consignee_name": consigneeName,
        "consignee_address": consigneeAddress,
        "loading_port_name": loadingPortName,
        "destination_port_name": destinationPortName,
        "departure": departure,
        "arrival": arrival,
      };
}

class ContainerDocument {
  int id;
  dynamic containerId;
  dynamic filename;
  dynamic filepath;
  dynamic type;
  dynamic filesize;
  dynamic ownerId;
  dynamic title;
  dynamic ctime;

  ContainerDocument({
    required this.id,
    this.containerId,
    this.filename,
    this.filepath,
    this.type,
    this.filesize,
    this.ownerId,
    this.title,
    this.ctime,
  });

  factory ContainerDocument.fromJson(Map<String, dynamic> json) =>
      ContainerDocument(
        id: json["id"],
        containerId: json["container_id"],
        filename: json["filename"],
        filepath: json["filepath"],
        type: json["type"],
        filesize: json["filesize"],
        ownerId: json["owner_id"],
        title: json["title"],
        ctime: json["ctime"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "container_id": containerId,
        "filename": filename,
        "filepath": filepath,
        "type": type,
        "filesize": filesize,
        "owner_id": ownerId,
        "title": title,
        "ctime": ctime,
      };
}

class VehicleElement {
  int id;
  dynamic userId;
  dynamic vehicleId;
  dynamic assignedTo;
  AppUser? user;
  Vehicle? vehicle;

  VehicleElement({
    required this.id,
    this.userId,
    this.vehicleId,
    this.assignedTo,
    this.user,
    this.vehicle,
  });

  factory VehicleElement.fromJson(Map<String, dynamic> json) => VehicleElement(
        id: json["id"],
        userId: json["user_id"],
        vehicleId: json["vehicle_id"],
        assignedTo: json["assigned_to"],
        user: json["user"] == null ? null : AppUser.fromJson(json["user"]),
        vehicle:
            json["vehicle"] == null ? null : Vehicle.fromJson(json["vehicle"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "vehicle_id": vehicleId,
        "assigned_to": assignedTo,
        "user": user!.toJson(),
        "vehicle": vehicle!.toJson(),
      };
}

class Consignee {
  int id;
  dynamic companyName;
  dynamic address;
  dynamic phoneNumber;
  dynamic fax;
  dynamic email;
  dynamic contactPerson;
  dynamic position;
  dynamic shipperId;
  dynamic aesNumberXtn;

  Consignee({
    required this.id,
    required this.companyName,
    required this.address,
    required this.phoneNumber,
    required this.fax,
    required this.email,
    required this.contactPerson,
    required this.position,
    this.shipperId,
    this.aesNumberXtn,
  });

  factory Consignee.fromJson(Map<String, dynamic> json) => Consignee(
        id: json["id"],
        companyName: json["company_name"],
        address: json["address"],
        phoneNumber: json["phone_number"],
        fax: json["fax"],
        email: json["email"],
        contactPerson: json["contact_person"],
        position: json["position"],
        shipperId: json["shipper_id"],
        aesNumberXtn: json["aes_number_xtn"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "company_name": companyName,
        "address": address,
        "phone_number": phoneNumber,
        "fax": fax,
        "email": email,
        "contact_person": contactPerson,
        "position": position,
        "shipper_id": shipperId,
        "aes_number_xtn": aesNumberXtn,
      };
}

class LoadingPort {
  int id;
  dynamic name;
  dynamic position;
  dynamic selected;
  dynamic scacCode;

  LoadingPort({
    required this.id,
    required this.name,
    this.position,
    this.selected,
    this.scacCode,
  });

  factory LoadingPort.fromJson(Map<String, dynamic> json) => LoadingPort(
        id: json["id"],
        name: json["name"],
        position: json["position"],
        selected: json["selected"],
        scacCode: json["scac_code"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "position": position,
        "selected": selected,
        "scac_code": scacCode,
      };
}
