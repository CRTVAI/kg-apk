import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io' as io;
import 'dart:async';

class Db {
  static Database? _db;
  static String dbName = 'cargo.db';

  String noteTable = 'note_table';
  String containerTable = 'container_table';
  static String terminalVehicleTable = 'terminal_vehicle_table';
  static String newVehicleTable = 'new_vehicle_table';
  static String bookedVehicleTable = 'booked_vehicle_table';
  static String loadedVehicleTable = 'loaded_vehicle_table';
  static String shippedVehicleTable = 'shipped_vehicle_table';
  static String deliveredVehicleTable = 'delivered_vehicle_table';
  static String releasedClientVehicleTable = 'released_client_vehicle_table';
  static String terminalVehicleImageTable = 'terminal_vehicle_image_table';
  static String newVehicleImageTable = 'new_vehicle_image_table';
  static String bookedVehicleImageTable = 'booked_vehicle_image_table';
  static String loadedVehicleImageTable = 'loaded_vehicle_image_table';
  static String shippedVehicleImageTable = 'shipped_vehicle_image_table';
  static String deliveredVehicleImageTable = 'delivered_vehicle_image_table';
  static String releasedVehicleImageTable = 'released_vehicle_image_table';
  static String auctionTable = 'auction_table';
  static String statusTable = 'status_table';
  String colId = 'colId';
  String vehicleId = 'id';
  String vehicleImageId = 'vehicle_id';
  String containerId = 'id';
  String auctionId = 'auction_id';
  String shipperId = 'shipper_id';
  String shippingLineId = 'shipping_line_id';
  String shippingLineName = 'shipping_line_name';
  String consigneeId = 'consignee_id';
  String consigneeName = 'consignee_name';
  String consigneeAddress = 'consignee_address';
  String preCarriageId = 'pre_carriage_id';
  String vesselName = 'vessel_name';
  String loadingPortId = 'loading_port_id';
  String dischargePortId = 'discharge_port_id';
  String destinationPortId = 'destination_port_id';
  String notifyPartId = 'notify_part_id';
  String bookingNo = 'booking_no';
  String containerNo = 'container_no';
  String cutOff = 'cut_off';
  String departure = 'departure';
  String arrival = 'arrival';
  String pierTerminalId = 'pier_terminal_id';
  String contractNo = 'contract_no';
  String voyageNo = 'voyage_no';
  String sealNo = 'seal_no';
  String exportReference = 'export_reference';
  String domesticRouting = 'domestic_routing';
  String measurementId = 'measurement_id';
  String aesNrXtn = 'aes_nr_xtn';
  String aesNrItn = 'aes_nr_itn';
  String invoiceDate = 'invoice_date';
  String invoiceTerm = 'invoice_term';
  String arrivalYm = 'arrival_ym';
  String requestType = 'request_type';
  String dateCreated = 'date_created';
  String aesBlockBody = 'aes_block_body';
  String fowardingAgentId = 'fowarding_agent_id';
  String vgm = 'vgm';
  String notesDocument = 'notes_document';
  String auctionName = 'auction_name';
  String terminalName = 'terminal_name';
  String auctionLocationId = 'auction_location_id';
  String draft = 'draft';
  String statusId = 'status_id';
  String statusName = 'status_name';
  String loadingPortName = 'loading_port_name';
  String destinationPortName = 'destination_port_name';
  String buyerId = 'buyer_id';
  String description = 'description';
  String lotnumber = 'lotnumber';
  String fuelType = 'fuel_type';
  String notes = 'notes';
  String carPrice = 'car_price';
  String transportPrice = 'transport_price';
  String auctionPrice = 'auction_price';
  String serviceFee = 'service_fee';
  String draftExpenses = 'draft_expenses';

  String purchaseDate = 'purchase_date';
  String terminalId = 'terminal_id';
  String dispatchDate = 'dispatch_date';
  String deliveryDate = 'delivery_date';
  String deliveredOnDate = 'delivered_on_date';
  String vin = 'vin';
  String operable = 'operable';
  String keys = 'keys';
  String title = 'title';
  String engine = 'engine';
  String usetypeId = 'usetype_id';
  String bodytrimId = 'bodytrim_id';
  String classId = 'class_id';
  String weight = 'weight';
  String ownerId = 'owner_id';
  String containerBuyerId = 'container_buyer_id';
  String paidPrice = 'paid_price';
  String allPaid = 'all_paid';
  String pdate = 'pdate';
  String deliveredOnDateYm = 'delivered_on_date_ym';
  String pickupDate = 'pickup_date';
  String searchBody = 'search_body';
  String auctionBuyer = 'auction_buyer';
  String destinationManual = 'destination_manual';
  String clientName = 'client_name';
  String carrier = 'carrier';
  String position = 'position';
  String hasPhoto = 'has_photo';
  String ref = 'ref';
  String notesUser = 'notes_user';
  String createdAt = 'created_at';
  String updatedAt = 'updated_at';

  String vehicleImageid = 'vehicleImageid';
  String ctime = 'ctime';
  String filesize = 'filesize';
  String filename = 'filename';
  String filepath = 'filepath';
  String type = 'type';

  String name = 'name';
  String selected = 'selected';

  String colTitle = 'title';
  String colDescription = 'description';
  String colPriority = 'priority';
  String colDate = 'date';

  Future<Database?> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await initDb();
    return _db;
  }

  initDb() async {
    io.Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path, dbName);
    var db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return db;
  }

  _onCreate(Database db, int version) async {
    await tblPreference(db);
  }

  tblPreference(Database db) async {
    await db.execute(
        'CREATE TABLE $terminalVehicleTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, '
        '$vehicleId INTEGER, $auctionId INTEGER, $auctionName TEXT, $terminalName TEXT, $auctionLocationId INTEGER, $draft INTEGER, $statusId INTEGER, $statusName TEXT,'
        '$buyerId INTEGER, $description TEXT,$fuelType TEXT, $lotnumber TEXT, $notes TEXT, $carPrice TEXT, '
        '$transportPrice TEXT, $auctionPrice TEXT, $serviceFee TEXT, $draftExpenses TEXT, $destinationPortId INTEGER, '
        '$purchaseDate TEXT, $terminalId INTEGER, $dispatchDate TEXT,$deliveryDate TEXT, $deliveredOnDate TEXT, $vin TEXT, '
        '$operable INTEGER, $keys INTEGER, $title INTEGER, $engine TEXT, $usetypeId INTEGER, '
        '$bodytrimId INTEGER, $classId INTEGER, $weight TEXT, $ownerId INTEGER, $containerBuyerId INTEGER, '
        '$paidPrice TEXT, $allPaid INTEGER, $pdate TEXT, $deliveredOnDateYm INTEGER, $pickupDate TEXT, '
        '$searchBody TEXT, $auctionBuyer TEXT, $destinationManual TEXT, $clientName TEXT, $carrier TEXT, '
        '$position INTEGER, $hasPhoto INTEGER, $ref TEXT, $notesUser TEXT, $notesDocument TEXT, '
        '$createdAt TEXT, $updatedAt TEXT) ');

    await db.execute(
        'CREATE TABLE $newVehicleTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, '
        '$vehicleId INTEGER, $auctionId INTEGER, $auctionName TEXT,$terminalName TEXT, $auctionLocationId INTEGER, $draft INTEGER, $statusId INTEGER, $statusName TEXT,'
        '$buyerId INTEGER, $description TEXT,$fuelType TEXT, $lotnumber TEXT, $notes TEXT, $carPrice TEXT, '
        '$transportPrice TEXT, $auctionPrice TEXT, $serviceFee TEXT, $draftExpenses TEXT, $destinationPortId INTEGER, '
        '$purchaseDate TEXT, $terminalId INTEGER, $dispatchDate TEXT,$deliveryDate TEXT, $deliveredOnDate TEXT, $vin TEXT, '
        '$operable INTEGER, $keys INTEGER, $title INTEGER, $engine TEXT, $usetypeId INTEGER, '
        '$bodytrimId INTEGER, $classId INTEGER, $weight TEXT, $ownerId INTEGER, $containerBuyerId INTEGER, '
        '$paidPrice TEXT, $allPaid INTEGER, $pdate TEXT, $deliveredOnDateYm INTEGER, $pickupDate TEXT, '
        '$searchBody TEXT, $auctionBuyer TEXT, $destinationManual TEXT, $clientName TEXT, $carrier TEXT, '
        '$position INTEGER, $hasPhoto INTEGER, $ref TEXT, $notesUser TEXT, $notesDocument TEXT, '
        '$createdAt TEXT, $updatedAt TEXT) ');

    await db.execute(
        'CREATE TABLE $bookedVehicleTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, '
        '$vehicleId INTEGER, $auctionId INTEGER, $auctionName TEXT,$terminalName TEXT, $auctionLocationId INTEGER, $draft INTEGER, $statusId INTEGER, $statusName TEXT,'
        '$buyerId INTEGER, $description TEXT,$fuelType TEXT, $lotnumber TEXT, $notes TEXT, $carPrice TEXT, '
        '$transportPrice TEXT, $auctionPrice TEXT, $serviceFee TEXT, $draftExpenses TEXT, $destinationPortId INTEGER, '
        '$purchaseDate TEXT, $terminalId INTEGER, $dispatchDate TEXT,$deliveryDate TEXT, $deliveredOnDate TEXT, $vin TEXT, '
        '$operable INTEGER, $keys INTEGER, $title INTEGER, $engine TEXT, $usetypeId INTEGER, '
        '$bodytrimId INTEGER, $classId INTEGER, $weight TEXT, $ownerId INTEGER, $containerBuyerId INTEGER, '
        '$paidPrice TEXT, $allPaid INTEGER, $pdate TEXT, $deliveredOnDateYm INTEGER, $pickupDate TEXT, '
        '$searchBody TEXT, $auctionBuyer TEXT, $destinationManual TEXT, $clientName TEXT, $carrier TEXT, '
        '$position INTEGER, $hasPhoto INTEGER, $ref TEXT, $notesUser TEXT, $notesDocument TEXT, '
        '$createdAt TEXT, $updatedAt TEXT) ');

    await db.execute(
        'CREATE TABLE $loadedVehicleTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, '
        '$vehicleId INTEGER, $auctionId INTEGER, $auctionName TEXT,$terminalName TEXT, $auctionLocationId INTEGER, $draft INTEGER, $statusId INTEGER, $statusName TEXT,'
        '$buyerId INTEGER, $description TEXT,$fuelType TEXT, $lotnumber TEXT, $notes TEXT, $carPrice TEXT, '
        '$transportPrice TEXT, $auctionPrice TEXT, $serviceFee TEXT, $draftExpenses TEXT, $destinationPortId INTEGER, '
        '$purchaseDate TEXT, $terminalId INTEGER, $dispatchDate TEXT,$deliveryDate TEXT, $deliveredOnDate TEXT, $vin TEXT, '
        '$operable INTEGER, $keys INTEGER, $title INTEGER, $engine TEXT, $usetypeId INTEGER, '
        '$bodytrimId INTEGER, $classId INTEGER, $weight TEXT, $ownerId INTEGER, $containerBuyerId INTEGER, '
        '$paidPrice TEXT, $allPaid INTEGER, $pdate TEXT, $deliveredOnDateYm INTEGER, $pickupDate TEXT, '
        '$searchBody TEXT, $auctionBuyer TEXT, $destinationManual TEXT, $clientName TEXT, $carrier TEXT, '
        '$position INTEGER, $hasPhoto INTEGER, $ref TEXT, $notesUser TEXT, $notesDocument TEXT, '
        '$createdAt TEXT, $updatedAt TEXT) ');

    await db.execute(
        'CREATE TABLE $shippedVehicleTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, '
        '$vehicleId INTEGER, $auctionId INTEGER, $auctionName TEXT,$terminalName TEXT, $auctionLocationId INTEGER, $draft INTEGER, $statusId INTEGER, $statusName TEXT,'
        '$buyerId INTEGER, $description TEXT,$fuelType TEXT, $lotnumber TEXT, $notes TEXT, $carPrice TEXT, '
        '$transportPrice TEXT, $auctionPrice TEXT, $serviceFee TEXT, $draftExpenses TEXT, $destinationPortId INTEGER, '
        '$purchaseDate TEXT, $terminalId INTEGER, $dispatchDate TEXT,$deliveryDate TEXT, $deliveredOnDate TEXT, $vin TEXT, '
        '$operable INTEGER, $keys INTEGER, $title INTEGER, $engine TEXT, $usetypeId INTEGER, '
        '$bodytrimId INTEGER, $classId INTEGER, $weight TEXT, $ownerId INTEGER, $containerBuyerId INTEGER, '
        '$paidPrice TEXT, $allPaid INTEGER, $pdate TEXT, $deliveredOnDateYm INTEGER, $pickupDate TEXT, '
        '$searchBody TEXT, $auctionBuyer TEXT, $destinationManual TEXT, $clientName TEXT, $carrier TEXT, '
        '$position INTEGER, $hasPhoto INTEGER, $ref TEXT, $notesUser TEXT, $notesDocument TEXT, '
        '$createdAt TEXT, $updatedAt TEXT) ');

    await db.execute(
        'CREATE TABLE $deliveredVehicleTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, '
        '$vehicleId INTEGER, $auctionId INTEGER, $auctionName TEXT,$terminalName TEXT, $auctionLocationId INTEGER, $draft INTEGER, $statusId INTEGER, $statusName TEXT,'
        '$buyerId INTEGER, $description TEXT,$fuelType TEXT, $lotnumber TEXT, $notes TEXT, $carPrice TEXT, '
        '$transportPrice TEXT, $auctionPrice TEXT, $serviceFee TEXT, $draftExpenses TEXT, $destinationPortId INTEGER, '
        '$purchaseDate TEXT, $terminalId INTEGER, $dispatchDate TEXT,$deliveryDate TEXT, $deliveredOnDate TEXT, $vin TEXT, '
        '$operable INTEGER, $keys INTEGER, $title INTEGER, $engine TEXT, $usetypeId INTEGER, '
        '$bodytrimId INTEGER, $classId INTEGER, $weight TEXT, $ownerId INTEGER, $containerBuyerId INTEGER, '
        '$paidPrice TEXT, $allPaid INTEGER, $pdate TEXT, $deliveredOnDateYm INTEGER, $pickupDate TEXT, '
        '$searchBody TEXT, $auctionBuyer TEXT, $destinationManual TEXT, $clientName TEXT, $carrier TEXT, '
        '$position INTEGER, $hasPhoto INTEGER, $ref TEXT, $notesUser TEXT, $notesDocument TEXT, '
        '$createdAt TEXT, $updatedAt TEXT) ');

    await db.execute(
        'CREATE TABLE $releasedClientVehicleTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, '
        '$vehicleId INTEGER, $auctionId INTEGER, $auctionName TEXT,$terminalName TEXT, $auctionLocationId INTEGER, $draft INTEGER, $statusId INTEGER, $statusName TEXT,'
        '$buyerId INTEGER, $description TEXT,$fuelType TEXT, $lotnumber TEXT, $notes TEXT, $carPrice TEXT, '
        '$transportPrice TEXT, $auctionPrice TEXT, $serviceFee TEXT, $draftExpenses TEXT, $destinationPortId INTEGER, '
        '$purchaseDate TEXT, $terminalId INTEGER, $dispatchDate TEXT,$deliveryDate TEXT, $deliveredOnDate TEXT, $vin TEXT, '
        '$operable INTEGER, $keys INTEGER, $title INTEGER, $engine TEXT, $usetypeId INTEGER, '
        '$bodytrimId INTEGER, $classId INTEGER, $weight TEXT, $ownerId INTEGER, $containerBuyerId INTEGER, '
        '$paidPrice TEXT, $allPaid INTEGER, $pdate TEXT, $deliveredOnDateYm INTEGER, $pickupDate TEXT, '
        '$searchBody TEXT, $auctionBuyer TEXT, $destinationManual TEXT, $clientName TEXT, $carrier TEXT, '
        '$position INTEGER, $hasPhoto INTEGER, $ref TEXT, $notesUser TEXT, $notesDocument TEXT, '
        '$createdAt TEXT, $updatedAt TEXT) ');

    await db.execute(
        'CREATE TABLE $terminalVehicleImageTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, '
        '$vehicleImageid INTEGER, $vehicleId INTEGER, $ctime TEXT, $filesize INTEGER, $ownerId INTEGER, '
        '$title TEXT, $filename TEXT, $filepath TEXT, $notes TEXT, $type TEXT)');

    await db.execute(
        'CREATE TABLE $newVehicleImageTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, '
        '$vehicleId INTEGER, $vehicleImageId INTEGER, $ctime TEXT, $filesize INTEGER, $ownerId INTEGER, '
        '$title TEXT, $filename TEXT, $filepath TEXT, $notes TEXT, $type TEXT)');

    await db.execute(
        'CREATE TABLE $bookedVehicleImageTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, '
        '$vehicleImageid INTEGER, $vehicleId INTEGER, $ctime TEXT, $filesize INTEGER, $ownerId INTEGER, '
        '$title TEXT, $filename TEXT, $filepath TEXT, $notes TEXT, $type TEXT)');

    await db.execute(
        'CREATE TABLE $loadedVehicleImageTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, '
        '$vehicleImageid INTEGER, $vehicleId INTEGER, $ctime TEXT, $filesize INTEGER, $ownerId INTEGER, '
        '$title TEXT, $filename TEXT, $filepath TEXT, $notes TEXT, $type TEXT)');

    await db.execute(
        'CREATE TABLE $shippedVehicleImageTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, '
        '$vehicleImageid INTEGER, $vehicleId INTEGER, $ctime TEXT, $filesize INTEGER, $ownerId INTEGER, '
        '$title TEXT, $filename TEXT, $filepath TEXT, $notes TEXT, $type TEXT)');

    await db.execute(
        'CREATE TABLE $deliveredVehicleImageTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, '
        '$vehicleImageid INTEGER, $vehicleId INTEGER, $ctime TEXT, $filesize INTEGER, $ownerId INTEGER, '
        '$title TEXT, $filename TEXT, $filepath TEXT, $notes TEXT, $type TEXT)');

    await db.execute(
        'CREATE TABLE $releasedVehicleImageTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, '
        '$vehicleImageid INTEGER, $vehicleId INTEGER, $ctime TEXT, $filesize INTEGER, $ownerId INTEGER, '
        '$title TEXT, $filename TEXT, $filepath TEXT, $notes TEXT, $type TEXT)');

    await db.execute(
        'CREATE TABLE $auctionTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, '
        '$auctionId INTEGER, $name TEXT, $position INTEGER, $selected INTEGER)');

    await db.execute(
        'CREATE TABLE $statusTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, '
        '$auctionId INTEGER, $name TEXT, $position INTEGER, $selected INTEGER)');
    await db.execute(
        'CREATE TABLE $containerTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, '
        '$statusName TEXT, $shippingLineName TEXT, $consigneeName TEXT, $consigneeAddress TEXT, '
        '$loadingPortName TEXT, $destinationPortName TEXT, $departure TEXT, $arrival TEXT, '
        '$containerId INTEGER, $statusId INTEGER, $shipperId INTEGER, $shippingLineId INTEGER, $bookingNo TEXT, $containerNo TEXT)');
  }
}
