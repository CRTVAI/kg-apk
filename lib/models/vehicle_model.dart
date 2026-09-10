class Vehicle {
  int id;
  dynamic auctionId;
  dynamic auctionName;
  dynamic terminalName;
  dynamic auctionLocationId;
  dynamic draft;
  dynamic statusId;
  dynamic statusName;
  dynamic buyerId;
  dynamic description;
  dynamic lotnumber;
  dynamic notes;
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
  dynamic deliveredOnDate;
  dynamic vin;
  dynamic operable;
  dynamic keys;
  dynamic title;
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
  dynamic position;
  dynamic hasPhoto;
  dynamic ref;
  dynamic notesUser;
  dynamic notesDocument;
  dynamic createdAt;
  dynamic updatedAt;
  dynamic fuelType;
  List<VehicleImage> vehicleImages;
  Auction? auction;
  Auction? status;
  Auction? termianl;

  Vehicle(
      {required this.id,
      this.auctionId,
      this.auctionName,
      this.terminalName,
      this.auctionLocationId,
      this.draft,
      this.statusId,
      this.statusName,
      this.buyerId,
      this.description,
      this.lotnumber,
      this.notes,
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
      this.deliveredOnDate,
      this.vin,
      this.operable,
      this.keys,
      this.title,
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
      this.position,
      this.hasPhoto,
      this.ref,
      this.notesUser,
      this.notesDocument,
      this.createdAt,
      this.updatedAt,
      required this.vehicleImages,
      this.auction,
      this.status,
      this.termianl,
      this.fuelType});

  factory Vehicle.fromJson(Map<dynamic, dynamic> json) => Vehicle(
        id: json["id"],
        auctionId: json["auction_id"],
        auctionName: json["auction"] == null
            ? ''
            : Auction.fromJson(json["auction"]).name,
        terminalName: json["terminal"] == null
            ? ''
            : Auction.fromJson(json["terminal"]).name,
        auctionLocationId: json["auction_location_id"],
        draft: json["draft"],
        statusId: json["status_id"],
        statusName:
            json["status"] == null ? '' : Auction.fromJson(json["status"]).name,
        buyerId: json["buyer_id"],
        description: json["description"],
        lotnumber: json["lotnumber"],
        notes: json["notes"],
        carPrice: json["car_price"],
        transportPrice: json["transport_price"],
        auctionPrice: json["auction_price"],
        serviceFee: json["service_fee"],
        draftExpenses: json["draft_expenses"],
        destinationPortId: json["destination_port_id"],
        purchaseDate: json["purchase_date"],
        terminalId: json["terminal_id"],
        dispatchDate: json["dispatch_date"],
        deliveryDate: json["delivery_date"],
        deliveredOnDate: json["delivered_on_date"],
        vin: json["vin"],
        operable: json["operable"],
        keys: json["keys"],
        title: json["title"],
        engine: json["engine"],
        usetypeId: json["usetype_id"],
        bodytrimId: json["bodytrim_id"],
        classId: json["class_id"],
        weight: json["weight"],
        ownerId: json["owner_id"],
        containerBuyerId: json["container_buyer_id"],
        paidPrice: json["paid_price"],
        allPaid: json["all_paid"],
        pdate: json["pdate"],
        deliveredOnDateYm: json["delivered_on_date_ym"],
        pickupDate: json["pickup_date"],
        searchBody: json["search_body"],
        auctionBuyer: json["auction_buyer"],
        destinationManual: json["destination_manual"],
        clientName: json["client_name"],
        carrier: json["carrier"],
        position: json["position"],
        hasPhoto: json["has_photo"],
        ref: json["ref"],
        notesUser: json["notes_user"],
        notesDocument: json["notes_document"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        fuelType: json["fuel_type"] == null ? '' : json['fuel_type'],
        vehicleImages: json["vehicle_images"] == null
            ? []
            : List<VehicleImage>.from(
                json["vehicle_images"].map((x) => VehicleImage.fromJson(x))),
        auction:
            json["auction"] == null ? null : Auction.fromJson(json["auction"]),
        status:
            json["status"] == null ? null : Auction.fromJson(json["status"]),
        termianl: json["terminal"] == null
            ? null
            : Auction.fromJson(json["terminal"]),
      );

  factory Vehicle.fromMap(Map<dynamic, dynamic> json) => Vehicle(
        id: json["id"],
        auctionId: json["auction_id"],
        auctionName: json["auction_name"],
        terminalName: json["terminal_name"],
        auctionLocationId: json["auction_location_id"],
        draft: json["draft"],
        statusId: json["status_id"],
        statusName: json["status_name"],
        buyerId: json["buyer_id"],
        description: json["description"],
        lotnumber: json["lotnumber"],
        notes: json["notes"],
        carPrice: json["car_price"],
        transportPrice: json["transport_price"],
        auctionPrice: json["auction_price"],
        serviceFee: json["service_fee"],
        draftExpenses: json["draft_expenses"],
        destinationPortId: json["destination_port_id"],
        purchaseDate: json["purchase_date"],
        terminalId: json["terminal_id"],
        dispatchDate: json["dispatch_date"],
        deliveryDate: json["delivery_date"],
        deliveredOnDate: json["delivered_on_date"],
        vin: json["vin"],
        operable: json["operable"],
        keys: json["keys"],
        title: json["title"],
        engine: json["engine"],
        usetypeId: json["usetype_id"],
        bodytrimId: json["bodytrim_id"],
        classId: json["class_id"],
        weight: json["weight"],
        ownerId: json["owner_id"],
        containerBuyerId: json["container_buyer_id"],
        paidPrice: json["paid_price"],
        allPaid: json["all_paid"],
        pdate: json["pdate"],
        deliveredOnDateYm: json["delivered_on_date_ym"],
        pickupDate: json["pickup_date"],
        searchBody: json["search_body"],
        auctionBuyer: json["auction_buyer"],
        destinationManual: json["destination_manual"],
        clientName: json["client_name"],
        carrier: json["carrier"],
        position: json["position"],
        hasPhoto: json["has_photo"],
        ref: json["ref"],
        fuelType: json["fuel_type"] == null ? '' : json['fuel_type'],
        notesUser: json["notes_user"],
        notesDocument: json["notes_document"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        vehicleImages: json["vehicle_images"] == null
            ? []
            : List<VehicleImage>.from(
                json["vehicle_images"].map((x) => VehicleImage.fromJson(x))),
        auction:
            json["auction"] == null ? null : Auction.fromJson(json["auction"]),
        status:
            json["status"] == null ? null : Auction.fromJson(json["status"]),
        termianl: json["terminal"] == null
            ? null
            : Auction.fromJson(json["terminal"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "auction_id": auctionId,
        "auction_name": auctionName,
        "terminal_name": terminalName,
        "auction_location_id": auctionLocationId,
        "draft": draft,
        "status_id": statusId,
        "status_name": statusName,
        "buyer_id": buyerId,
        "description": description,
        "lotnumber": lotnumber,
        "notes": notes,
        "car_price": carPrice,
        "transport_price": transportPrice,
        "auction_price": auctionPrice,
        "service_fee": serviceFee,
        "draft_expenses": draftExpenses,
        "destination_port_id": destinationPortId,
        "purchase_date": purchaseDate,
        "terminal_id": terminalId,
        "dispatch_date": dispatchDate,
        "delivery_date": deliveryDate,
        "delivered_on_date": deliveredOnDate,
        "vin": vin,
        "operable": operable,
        "keys": keys,
        "title": title,
        "engine": engine,
        'fuel_type': fuelType,
        "usetype_id": usetypeId,
        "bodytrim_id": bodytrimId,
        "class_id": classId,
        "weight": weight,
        "owner_id": ownerId,
        "container_buyer_id": containerBuyerId,
        "paid_price": paidPrice,
        "all_paid": allPaid,
        "pdate": pdate,
        "delivered_on_date_ym": deliveredOnDateYm,
        "pickup_date": pickupDate,
        "search_body": searchBody,
        "auction_buyer": auctionBuyer,
        "destination_manual": destinationManual,
        "client_name": clientName,
        "carrier": carrier,
        "position": position,
        "has_photo": hasPhoto,
        "ref": ref,
        "notes_user": notesUser,
        "notes_document": notesDocument,
        "created_at": createdAt,
        "updated_at": updatedAt,
        // "vehicle_images": List<dynamic>.from(vehicleImages.map((x) => x.toJson())),
      };

  @override
  String toString() {
    return '$description';
  }
}

class Auction {
  dynamic id;
  dynamic name;
  dynamic position;
  dynamic selected;

  Auction({
    this.id,
    this.name,
    this.position,
    this.selected,
  });

  factory Auction.fromJson(Map<String, dynamic> json) => Auction(
        id: json["id"],
        name: json["name"],
        position: json["position"],
        selected: json["selected"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "position": position,
        "selected": selected,
      };
}

class VehicleImage {
  dynamic id;
  dynamic vehicleId;
  dynamic ctime;
  dynamic filesize;
  dynamic ownerId;
  dynamic title;
  dynamic filename;
  dynamic filepath;
  dynamic type;

  VehicleImage({
    this.id,
    this.vehicleId,
    this.ctime,
    this.filesize,
    this.ownerId,
    this.title,
    this.filename,
    this.filepath,
    this.type,
  });

  factory VehicleImage.fromJson(Map<dynamic, dynamic> json) => VehicleImage(
        id: json["id"],
        vehicleId: json["vehicle_id"],
        ctime: json["ctime"],
        filesize: json["filesize"],
        ownerId: json["owner_id"],
        title: json["title"],
        filename: json["filename"],
        filepath: json["filepath"],
        type: json["type"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "vehicle_id": vehicleId,
        "ctime": ctime,
        "filesize": filesize,
        "owner_id": ownerId,
        "title": title,
        "filename": filename,
        "filepath": filepath,
        "type": type,
      };
}
