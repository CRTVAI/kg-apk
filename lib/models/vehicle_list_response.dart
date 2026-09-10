// To parse this JSON data, do
//
//     final vehicleListResponse = vehicleListResponseFromJson(jsonString);

import 'dart:convert';

import 'package:cargo/models/container_list_response.dart';
import 'package:cargo/models/login_response.dart';

import 'destination_port_response.dart';

VehicleListResponse vehicleListResponseFromJson(String str) =>
    VehicleListResponse.fromJson(json.decode(str));
VehicleList notificationResponseFromJson(String str) =>
    VehicleList.fromJson(json.decode(str));

String vehicleListResponseToJson(VehicleListResponse data) =>
    json.encode(data.toJson());

class VehicleListResponse {
  dynamic success;
  List<VehicleList> vehicleList;
  dynamic message;

  VehicleListResponse({
    this.success,
    required this.vehicleList,
    this.message,
  });

  factory VehicleListResponse.fromJson(Map<String, dynamic> json) =>
      VehicleListResponse(
        success: json["success"],
        vehicleList: List<VehicleList>.from(
            json["data"].map((x) => VehicleList.fromJson(x))),
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "data": List<dynamic>.from(vehicleList.map((x) => x.toJson())),
        "message": message,
      };
}

class VehicleList {
  int id;
  dynamic userId;
  dynamic vehicleId;
  dynamic assignedTo;
  dynamic paymentStatus;
  AppUser? user;
  Vehicle? vehicle;
  Containers? container;
  List<VehicleSubUserAssignment>? subUsers;

  VehicleList({
    required this.id,
    this.userId,
    this.vehicleId,
    this.assignedTo,
    this.paymentStatus,
    this.user,
    this.vehicle,
    this.container,
    this.subUsers,
  });

  factory VehicleList.fromJson(Map<dynamic, dynamic> json) => VehicleList(
        id: json["id"],
        userId: json["user_id"],
        vehicleId: json["vehicle_id"],
        assignedTo: json["assigned_to"],
        paymentStatus: json["payment_status"],
        user: json["user"] == null ? null : AppUser.fromJson(json["user"]),
        vehicle:
            json["vehicle"] == null ? null : Vehicle.fromJson(json["vehicle"]),
        container: json["container"] == null
            ? null
            : Containers.fromJson(json["container"]),
        subUsers: json["sub_users"] == null
            ? []
            : List<VehicleSubUserAssignment>.from(json["sub_users"]
                .map((x) => VehicleSubUserAssignment.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "vehicle_id": vehicleId,
        "assigned_to": assignedTo,
        "payment_status": paymentStatus,
        "user": user!.toJson(),
        "vehicle": vehicle!.toJson(),
        "container": container?.toJson(),
        "sub_users": List<dynamic>.from(
            (subUsers ?? <VehicleSubUserAssignment>[]).map((x) => x.toJson())),
      };
  @override
  String toString() {
    return '${vehicle!.modal == null ? '' : vehicle!.modal} ${vehicle!.name == null ? '' : vehicle!.name} ${vehicle!.companyName == null ? '' : vehicle!.companyName}';
  }
}

class VehicleSubUserAssignment {
  int id;
  dynamic userId;
  dynamic vehicleId;
  AppUser? user;

  VehicleSubUserAssignment({
    required this.id,
    this.userId,
    this.vehicleId,
    this.user,
  });

  factory VehicleSubUserAssignment.fromJson(Map<dynamic, dynamic> json) =>
      VehicleSubUserAssignment(
        id: json["id"],
        userId: json["user_id"],
        vehicleId: json["vehicle_id"],
        user: json["user"] == null ? null : AppUser.fromJson(json["user"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "vehicle_id": vehicleId,
        "user": user?.toJson(),
      };
}

class Consignee {
  dynamic id;
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

class VehicleImage {
  int id;
  dynamic containerId;
  dynamic filename;
  dynamic filepath;
  dynamic type;
  dynamic filesize;
  dynamic ownerId;
  dynamic title;
  dynamic vehicleId;

  VehicleImage({
    required this.id,
    this.containerId,
    this.filename,
    this.filepath,
    this.type,
    this.filesize,
    this.ownerId,
    this.title,
    this.vehicleId,
  });

  factory VehicleImage.fromJson(Map<dynamic, dynamic> json) => VehicleImage(
        id: json["id"],
        containerId: json["container_id"],
        filename: json["filename"],
        filepath: json["filepath"],
        type: json["type"],
        filesize: json["filesize"],
        ownerId: json["owner_id"],
        title: json["title"],
        vehicleId: json["vehicle_id"],
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
        "vehicle_id": vehicleId,
      };
}

class Auction {
  int id;
  dynamic name;
  dynamic position;
  dynamic selected;
  dynamic scacCode;
  dynamic auctionId;

  Auction({
    required this.id,
    required this.name,
    required this.position,
    this.selected,
    this.scacCode,
    this.auctionId,
  });

  factory Auction.fromJson(Map<String, dynamic> json) => Auction(
        id: json["id"],
        name: json["name"],
        position: json["position"],
        selected: json["selected"],
        scacCode: json["scac_code"],
        auctionId: json["auction_id"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "position": position,
        "selected": selected,
        "scac_code": scacCode,
        "auction_id": auctionId,
      };
}

class Vehicle {
  int id;
  dynamic auctionId;
  dynamic address;
  dynamic location;
  dynamic transportationAddress;
  dynamic pickupAddress;
  dynamic deliveryAddress;
  dynamic auctionLocationId;
  dynamic draft;
  dynamic statusId;
  dynamic buyerId;
  dynamic companyName;
  dynamic name;
  dynamic modal;
  dynamic description;
  dynamic lotnumber;
  dynamic updateDestination;
  dynamic updateCustomer;
  dynamic notes;
  dynamic transportationNotes;
  dynamic carPrice;
  dynamic transportPrice;
  dynamic auctionPrice;
  dynamic serviceFee;
  dynamic draftExpenses;
  dynamic destinationPortId;
  dynamic purchaseDate;
  dynamic terminalId;
  dynamic dispatchDate;
  dynamic deliveryDate;
  dynamic dueDate;
  dynamic deliveredOnDate;
  dynamic towingPrice;
  dynamic vin;
  dynamic operable;
  dynamic keys;
  dynamic title;
  dynamic fuelType;
  dynamic engine;
  dynamic usetypeId;
  dynamic bodytrimId;
  dynamic classId;
  dynamic weight;
  dynamic ownerId;
  dynamic containerBuyerId;
  dynamic paidPrice;
  dynamic allPaid;
  dynamic pdate;
  dynamic deliveredOnDateYm;
  dynamic pickupDate;
  dynamic searchBody;
  dynamic auctionBuyer;
  dynamic destinationManual;
  dynamic clientName;
  dynamic carrier;
  dynamic isDispatched;
  dynamic cdListingId;
  dynamic position;
  dynamic hasPhoto;
  dynamic ref;
  dynamic notesUser;
  dynamic notesDocument;
  dynamic customerName;
  PendingImages? pendingImages;
  dynamic createdAt;
  dynamic updatedAt;
  List<VehicleImage>? vehicleImages;
  List<VehicleDocument>? vehicleDocuments;
  List<dynamic>? fines;
  Auction? auction;
  Auction? auctionLocation;
  Auction? terminal;
  Auction? status;
  AppUser? buyer;
  DestinationPort? destinationPort;

  Vehicle(
      {required this.id,
      this.auctionId,
      this.address,
      this.location,
      this.transportationAddress,
      this.pickupAddress,
      this.deliveryAddress,
      this.auctionLocationId,
      this.draft,
      this.statusId,
      this.buyerId,
      this.updateDestination,
      this.updateCustomer,
      this.companyName,
      this.name,
      this.modal,
      this.description,
      this.lotnumber,
      this.notes,
      this.transportationNotes,
      this.carPrice,
      this.transportPrice,
      this.auctionPrice,
      this.serviceFee,
      this.draftExpenses,
      this.destinationPortId,
      this.purchaseDate,
      this.terminalId,
      this.dispatchDate,
      this.deliveryDate,
      this.dueDate,
      this.deliveredOnDate,
      this.towingPrice,
      this.vin,
      this.operable,
      this.keys,
      this.title,
      this.fuelType,
      this.engine,
      this.usetypeId,
      this.bodytrimId,
      this.classId,
      this.weight,
      this.ownerId,
      this.containerBuyerId,
      this.paidPrice,
      this.allPaid,
      this.pdate,
      this.deliveredOnDateYm,
      this.pickupDate,
      this.searchBody,
      this.auctionBuyer,
      this.destinationManual,
      this.clientName,
      this.carrier,
      this.isDispatched,
      this.cdListingId,
      this.position,
      this.hasPhoto,
      this.ref,
      this.notesUser,
      this.notesDocument,
      this.customerName,
      this.pendingImages,
      this.createdAt,
      this.updatedAt,
      this.vehicleImages,
      this.vehicleDocuments,
      this.fines,
      this.auction,
      this.auctionLocation,
      this.terminal,
      this.status,
      this.buyer,
      this.destinationPort});

  static DateTime? _safeDate(dynamic value) {
    final text = value?.toString().trim() ?? '';
    if (text.isEmpty || text.startsWith('0000')) return null;
    return DateTime.tryParse(text);
  }

  factory Vehicle.fromJson(Map<String, dynamic> json) => Vehicle(
        id: json["id"],
        auctionId: json["auction_id"],
        address: json["address"],
        location: json["location"],
        transportationAddress: json["transportation_address"],
        pickupAddress: json["pickup_address"],
        deliveryAddress: json["delivery_address"],
        auctionLocationId: json["auction_location_id"],
        draft: json["draft"],
        statusId: json["status_id"],
        buyerId: json["buyer_id"],
        companyName: json["company_name"],
        name: json["name"],
        modal: json["modal"],
        description: json["description"],
        lotnumber: json["lotnumber"] == null ? '' : json["lotnumber"],
        notes: json["notes"],
        updateDestination: json["update_destination"],
        updateCustomer: json["update_customer"],
        transportationNotes: json["transportation_notes"],
        carPrice: json["car_price"],
        transportPrice: json["transport_price"],
        auctionPrice: json["auction_price"],
        serviceFee: json["service_fee"],
        draftExpenses: json["draft_expenses"],
        destinationPortId: json["destination_port_id"],
        purchaseDate: _safeDate(json["purchase_date"]),
        terminalId: json["terminal_id"],
        dispatchDate: json["dispatch_date"],
        deliveryDate: json["delivery_date"],
        dueDate: _safeDate(json["due_date"]),
        deliveredOnDate: json["delivered_on_date"],
        towingPrice: json["towing_price"],
        vin: json["vin"],
        operable: json["operable"],
        keys: json["keys"],
        title: json["title"],
        fuelType: json["fuel_type"],
        engine: json["engine"],
        usetypeId: json["usetype_id"],
        bodytrimId: json["bodytrim_id"],
        classId: json["class_id"],
        weight: json["weight"],
        ownerId: json["owner_id"],
        containerBuyerId: json["container_buyer_id"],
        paidPrice: json["paid_price"],
        allPaid: json["all_paid"],
        pdate: _safeDate(json["pdate"]),
        deliveredOnDateYm: json["delivered_on_date_ym"],
        pickupDate: json["pickup_date"],
        searchBody: json["search_body"],
        auctionBuyer:
            json["auction_buyer"] == null ? '' : json["auction_buyer"],
        destinationManual: json["destination_manual"],
        clientName: json["client_name"] == null ? '' : json["client_name"],
        carrier: json["carrier"],
        isDispatched: json["is_dispatched"],
        cdListingId: json["cd_listing_id"],
        position: json["position"],
        hasPhoto: json["has_photo"],
        ref: json["ref"],
        notesUser: json["notes_user"],
        notesDocument: json["notes_document"],
        customerName: json["customer_name"],
        pendingImages: json["pending_images"] == null
            ? null
            : PendingImages.fromJson(json["pending_images"]),
        createdAt: _safeDate(json["created_at"]),
        updatedAt: _safeDate(json["updated_at"]),
        vehicleImages: json["vehicle_images"] == null
            ? []
            : List<VehicleImage>.from(
                json["vehicle_images"].map((x) => VehicleImage.fromJson(x))),
        vehicleDocuments: json["vehicle_documents"] == null
            ? []
            : List<VehicleDocument>.from(json["vehicle_documents"]
                .map((x) => VehicleDocument.fromJson(x))),
        fines: json["fines"] == null
            ? []
            : List<dynamic>.from(json["fines"].map((x) => x)),
        auction:
            json["auction"] == null ? null : Auction.fromJson(json["auction"]),
        auctionLocation: json["auction_location"] == null
            ? null
            : Auction.fromJson(json["auction_location"]),
        terminal: json["terminal"] == null
            ? null
            : Auction.fromJson(json["terminal"]),
        status:
            json["status"] == null ? null : Auction.fromJson(json["status"]),
        buyer: json["buyer"] == null ? null : AppUser.fromJson(json["buyer"]),
        destinationPort: json["destination_port"] == null
            ? null
            : DestinationPort.fromJson(json["destination_port"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "auction_id": auctionId,
        "address": address,
        "location": location,
        "transportation_address": transportationAddress,
        "pickup_address": pickupAddress,
        "delivery_address": deliveryAddress,
        "auction_location_id": auctionLocationId,
        "draft": draft,
        "status_id": statusId,
        "buyer_id": buyerId,
        "company_name": companyName,
        "name": name,
        "modal": modal,
        "description": description,
        "lotnumber": lotnumber,
        "notes": notes,
        "update_customer": updateCustomer,
        "transportation_notes": transportationNotes,
        "car_price": carPrice,
        "transport_price": transportPrice,
        "auction_price": auctionPrice,
        "service_fee": serviceFee,
        "draft_expenses": draftExpenses,
        "destination_port_id": destinationPortId,
        "purchase_date":
            "${purchaseDate!.year.toString().padLeft(4, '0')}-${purchaseDate!.month.toString().padLeft(2, '0')}-${purchaseDate!.day.toString().padLeft(2, '0')}",
        "terminal_id": terminalId,
        "dispatch_date": dispatchDate,
        "delivery_date": deliveryDate,
        "due_date":
            "${dueDate!.year.toString().padLeft(4, '0')}-${dueDate!.month.toString().padLeft(2, '0')}-${dueDate!.day.toString().padLeft(2, '0')}",
        "delivered_on_date": deliveredOnDate,
        "towing_price": towingPrice,
        "vin": vin,
        "operable": operable,
        "keys": keys,
        "title": title,
        "fuel_type": fuelType,
        "engine": engine,
        "usetype_id": usetypeId,
        "bodytrim_id": bodytrimId,
        "class_id": classId,
        "weight": weight,
        "owner_id": ownerId,
        "container_buyer_id": containerBuyerId,
        "paid_price": paidPrice,
        "all_paid": allPaid,
        "pdate": pdate?.toIso8601String(),
        "delivered_on_date_ym": deliveredOnDateYm,
        "pickup_date": pickupDate,
        "search_body": searchBody,
        "auction_buyer": auctionBuyer,
        "destination_manual": destinationManual,
        "client_name": clientName,
        "carrier": carrier,
        "is_dispatched": isDispatched,
        "cd_listing_id": cdListingId,
        "position": position,
        "has_photo": hasPhoto,
        "ref": ref,
        "notes_user": notesUser,
        "notes_document": notesDocument,
        "customer_name": customerName,
        "pending_images": pendingImages?.toJson(),
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "vehicle_images":
            List<dynamic>.from(vehicleImages!.map((x) => x.toJson())),
        "vehicle_documents":
            List<dynamic>.from(vehicleDocuments!.map((x) => x.toJson())),
        "fines": List<dynamic>.from(fines!.map((x) => x)),
        "auction": auction!.toJson(),
        "auction_location": auctionLocation!.toJson(),
        "terminal": terminal!.toJson(),
        "status": status!.toJson(),
        "buyer": buyer!.toJson(),
        "destination_port": destinationPort!.toJson(),
      };
}

class VehicleDocument {
  int id;
  dynamic vehicleId;
  dynamic filesize;
  dynamic filename;
  dynamic filepath;
  dynamic title;
  dynamic type;
  // DateTime createdAt;
  // DateTime updatedAt;

  VehicleDocument({
    required this.id,
    required this.vehicleId,
    required this.filesize,
    required this.filename,
    required this.filepath,
    this.title,
    this.type,
    // required this.createdAt,
    // required this.updatedAt,
  });

  factory VehicleDocument.fromJson(Map<String, dynamic> json) =>
      VehicleDocument(
        id: json["id"],
        vehicleId: json["vehicle_id"],
        filesize: json["filesize"],
        filename: json["filename"],
        filepath: json["filepath"],
        title: json["title"],
        type: json["type"],
        // createdAt: DateTime.parse(json["created_at"]),
        // updatedAt: DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "vehicle_id": vehicleId,
        "filesize": filesize,
        "filename": filename,
        "filepath": filepath,
        "title": title,
        "type": type,
        // "created_at": createdAt.toIso8601String(),
        // "updated_at": updatedAt.toIso8601String(),
      };
}

class PendingImages {
  PendingImages({this.images});

  final List<String>? images;

  factory PendingImages.fromJson(Map<String, dynamic> json) {
    final rawImages = json["images"];
    List<String> parsedImages = <String>[];
    if (rawImages is String && rawImages.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(rawImages);
        if (decoded is List) {
          parsedImages = decoded.map((item) => item.toString()).toList();
        }
      } catch (_) {
        parsedImages = <String>[];
      }
    } else if (rawImages is List) {
      parsedImages = rawImages.map((item) => item.toString()).toList();
    }
    return PendingImages(images: parsedImages);
  }

  Map<String, dynamic> toJson() => {
        "images": images,
      };
}
