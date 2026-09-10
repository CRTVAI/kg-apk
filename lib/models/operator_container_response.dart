// To parse this JSON data, do
//
//     final operatorContainerResponse = operatorContainerResponseFromJson(jsonString);

import 'dart:convert';

OperatorContainerResponse operatorContainerResponseFromJson(String str) =>
    OperatorContainerResponse.fromJson(json.decode(str));

String operatorContainerResponseToJson(OperatorContainerResponse data) =>
    json.encode(data.toJson());

class OperatorContainerResponse {
  dynamic success;
  OperatorContainerData operatorContainerData;
  dynamic message;

  OperatorContainerResponse({
    this.success,
    required this.operatorContainerData,
    this.message,
  });

  factory OperatorContainerResponse.fromJson(Map<String, dynamic> json) =>
      OperatorContainerResponse(
        success: json["success"],
        operatorContainerData: OperatorContainerData.fromJson(json["data"]),
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "data": operatorContainerData.toJson(),
        "message": message,
      };
}

class OperatorContainerData {
  List<OperatorContainer> containers;

  OperatorContainerData({
    required this.containers,
  });

  factory OperatorContainerData.fromJson(Map<String, dynamic> json) =>
      OperatorContainerData(
        containers: List<OperatorContainer>.from(
            json["containers"].map((x) => OperatorContainer.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "containers": List<dynamic>.from(containers.map((x) => x.toJson())),
      };
}

class OperatorContainer {
  int id;
  dynamic statusId;
  dynamic shipperId;
  dynamic shippingLineId;
  dynamic consigneeId;
  dynamic preCarriageId;
  dynamic vesselName;
  dynamic location;
  dynamic loadingPortId;
  dynamic dischargePortId;
  dynamic destinationPortId;
  dynamic notifyPartId;
  dynamic bookingNo;
  dynamic containerNo;
  DateTime? cutOff;
  DateTime? departure;
  DateTime? arrival;
  dynamic pierTerminalId;
  dynamic contractNo;
  dynamic voyageNo;
  dynamic sealNo;
  dynamic exportReference;
  dynamic domesticRouting;
  dynamic measurementId;
  dynamic aesNrXtn;
  dynamic aesNrItn;
  dynamic invoiceDate;
  dynamic invoiceTerm;
  DateTime? dateForLetter;
  dynamic draft;
  dynamic ownerId;
  dynamic arrivalYm;
  dynamic requestType;
  dynamic dateCreated;
  dynamic searchBody;
  dynamic aesBlockBody;
  dynamic allPaid;
  dynamic fowardingAgentId;
  dynamic vgm;
  dynamic notesDocument;
  dynamic deletedAt;
  DateTime? createdAt;
  DateTime? updatedAt;
  List<ContainerDocument>? containerDocuments;
  DestinationPort? status;
  Consignee? shipper;
  DestinationPort? shippingLine;
  Consignee? consignee;
  dynamic preCarriage;
  DestinationPort? loadingPort;
  DestinationPort? dischargePort;
  DestinationPort? destinationPort;
  DestinationPort? notifyParty;
  dynamic pierTerminal;
  DestinationPort? measurement;

  OperatorContainer({
    required this.id,
    this.statusId,
    this.shipperId,
    this.shippingLineId,
    this.consigneeId,
    this.preCarriageId,
    this.vesselName,
    this.location,
    this.loadingPortId,
    this.dischargePortId,
    this.destinationPortId,
    this.notifyPartId,
    this.bookingNo,
    this.containerNo,
    this.cutOff,
    this.departure,
    this.arrival,
    this.pierTerminalId,
    this.contractNo,
    this.voyageNo,
    this.sealNo,
    this.exportReference,
    this.domesticRouting,
    this.measurementId,
    this.aesNrXtn,
    this.aesNrItn,
    this.invoiceDate,
    this.invoiceTerm,
    this.dateForLetter,
    this.draft,
    this.ownerId,
    this.arrivalYm,
    this.requestType,
    this.dateCreated,
    this.searchBody,
    this.aesBlockBody,
    this.allPaid,
    this.fowardingAgentId,
    this.vgm,
    this.notesDocument,
    this.deletedAt,
    this.createdAt,
    this.updatedAt,
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
  });

  factory OperatorContainer.fromJson(Map<String, dynamic> json) =>
      OperatorContainer(
        id: json["id"],
        statusId: json["status_id"],
        shipperId: json["shipper_id"],
        shippingLineId: json["shipping_line_id"],
        consigneeId: json["consignee_id"],
        preCarriageId: json["pre_carriage_id"],
        vesselName: json["vessel_name"],
        location: json["location"],
        loadingPortId: json["loading_port_id"],
        dischargePortId: json["discharge_port_id"],
        destinationPortId: json["destination_port_id"],
        notifyPartId: json["notify_part_id"],
        bookingNo: json["booking_no"],
        containerNo: json["container_no"],
        cutOff:
            json["cut_off"] == null ? null : DateTime.parse(json["cut_off"]),
        departure: json["departure"] == null
            ? null
            : DateTime.parse(json["departure"]),
        arrival:
            json["arrival"] == null ? null : DateTime.parse(json["arrival"]),
        pierTerminalId: json["pier_terminal_id"],
        contractNo: json["contract_no"],
        voyageNo: json["voyage_no"],
        sealNo: json["seal_no"],
        exportReference: json["export_reference"],
        domesticRouting: json["domestic_routing"],
        measurementId: json["measurement_id"],
        aesNrXtn: json["aes_nr_xtn"],
        aesNrItn: json["aes_nr_itn"],
        invoiceDate: json["invoice_date"],
        invoiceTerm: json["invoice_term"],
        dateForLetter: json["date_for_letter"] == null
            ? null
            : DateTime.parse(json["date_for_letter"]),
        draft: json["draft"],
        ownerId: json["owner_id"],
        arrivalYm: json["arrival_ym"],
        requestType: json["request_type"],
        dateCreated: json["date_created"],
        searchBody: json["search_body"],
        aesBlockBody: json["aes_block_body"],
        allPaid: json["all_paid"],
        fowardingAgentId: json["fowarding_agent_id"],
        vgm: json["vgm"],
        notesDocument: json["notes_document"],
        deletedAt: json["deleted_at"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        containerDocuments: json["container_documents"] == null
            ? []
            : List<ContainerDocument>.from(json["container_documents"]
                .map((x) => ContainerDocument.fromJson(x))),
        status: json["status"] == null
            ? null
            : DestinationPort.fromJson(json["status"]),
        shipper: json["shipper"] == null
            ? null
            : Consignee.fromJson(json["shipper"]),
        shippingLine: json["shipping_line"] == null
            ? null
            : DestinationPort.fromJson(json["shipping_line"]),
        consignee: json["consignee"] == null
            ? null
            : Consignee.fromJson(json["consignee"]),
        preCarriage: json["pre_carriage"],
        loadingPort: json["loading_port"] == null
            ? null
            : DestinationPort.fromJson(json["loading_port"]),
        dischargePort: json["discharge_port"] == null
            ? null
            : DestinationPort.fromJson(json["discharge_port"]),
        destinationPort: json["destination_port"] == null
            ? null
            : DestinationPort.fromJson(json["destination_port"]),
        notifyParty: json["notify_party"] == null
            ? null
            : DestinationPort.fromJson(json["notify_party"]),
        pierTerminal: json["pier_terminal"],
        measurement: json["measurement"] == null
            ? null
            : DestinationPort.fromJson(json["measurement"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "status_id": statusId,
        "shipper_id": shipperId,
        "shipping_line_id": shippingLineId,
        "consignee_id": consigneeId,
        "pre_carriage_id": preCarriageId,
        "vessel_name": vesselName,
        "location": location,
        "loading_port_id": loadingPortId,
        "discharge_port_id": dischargePortId,
        "destination_port_id": destinationPortId,
        "notify_part_id": notifyPartId,
        "booking_no": bookingNo,
        "container_no": containerNo,
        "cut_off":
            "${cutOff!.year.toString().padLeft(4, '0')}-${cutOff!.month.toString().padLeft(2, '0')}-${cutOff!.day.toString().padLeft(2, '0')}",
        "departure":
            "${departure!.year.toString().padLeft(4, '0')}-${departure!.month.toString().padLeft(2, '0')}-${departure!.day.toString().padLeft(2, '0')}",
        "arrival":
            "${arrival!.year.toString().padLeft(4, '0')}-${arrival!.month.toString().padLeft(2, '0')}-${arrival!.day.toString().padLeft(2, '0')}",
        "pier_terminal_id": pierTerminalId,
        "contract_no": contractNo,
        "voyage_no": voyageNo,
        "seal_no": sealNo,
        "export_reference": exportReference,
        "domestic_routing": domesticRouting,
        "measurement_id": measurementId,
        "aes_nr_xtn": aesNrXtn,
        "aes_nr_itn": aesNrItn,
        "invoice_date": invoiceDate,
        "invoice_term": invoiceTerm,
        "date_for_letter":
            "${dateForLetter!.year.toString().padLeft(4, '0')}-${dateForLetter!.month.toString().padLeft(2, '0')}-${dateForLetter!.day.toString().padLeft(2, '0')}",
        "draft": draft,
        "owner_id": ownerId,
        "arrival_ym": arrivalYm,
        "request_type": requestType,
        "date_created": dateCreated,
        "search_body": searchBody,
        "aes_block_body": aesBlockBody,
        "all_paid": allPaid,
        "fowarding_agent_id": fowardingAgentId,
        "vgm": vgm,
        "notes_document": notesDocument,
        "deleted_at": deletedAt,
        "created_at": createdAt!.toIso8601String(),
        "updated_at": updatedAt!.toIso8601String(),
        "container_documents":
            List<dynamic>.from(containerDocuments!.map((x) => x.toJson())),
        "status": status!.toJson(),
        "shipper": shipper!.toJson(),
        "shipping_line": shippingLine!.toJson(),
        "consignee": consignee!.toJson(),
        "pre_carriage": preCarriage,
        "loading_port": loadingPort!.toJson(),
        "discharge_port": dischargePort!.toJson(),
        "destination_port": destinationPort!.toJson(),
        "notify_party": notifyParty!.toJson(),
        "pier_terminal": pierTerminal,
        "measurement": measurement!.toJson(),
      };

  @override
  String toString() {
    return '$containerNo';
  }
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
  String? aesNumberXtn;

  Consignee({
    required this.id,
    this.companyName,
    this.address,
    this.phoneNumber,
    this.fax,
    this.email,
    this.contactPerson,
    this.position,
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

class DestinationPort {
  int id;
  dynamic name;
  dynamic position;
  dynamic unloadingFee;
  dynamic deletedAt;
  dynamic createdAt;
  dynamic updatedAt;
  dynamic selected;
  dynamic scacCode;

  DestinationPort({
    required this.id,
    this.name,
    this.position,
    this.unloadingFee,
    required this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
    this.selected,
    this.scacCode,
  });

  factory DestinationPort.fromJson(Map<String, dynamic> json) =>
      DestinationPort(
        id: json["id"],
        name: json["name"],
        position: json["position"],
        unloadingFee: json["unloading_fee"],
        deletedAt: json["deleted_at"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        selected: json["selected"],
        scacCode: json["scac_code"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "position": position,
        "unloading_fee": unloadingFee,
        "deleted_at": deletedAt,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "selected": selected,
        "scac_code": scacCode,
      };
}
