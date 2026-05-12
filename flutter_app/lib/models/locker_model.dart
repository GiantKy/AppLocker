class LockerModel {
  final String id;
  final String lockerNumber;
  final String status;
  final String size;
  final String createdAt;

  LockerModel({
    required this.id,
    required this.lockerNumber,
    required this.status,
    required this.size,
    required this.createdAt,
  });

  factory LockerModel.fromJson(Map<String, dynamic> json) {
    return LockerModel(
      id: json['id'] ?? '',
      lockerNumber: json['locker_number'] ?? '',
      status: json['status'] ?? 'available',
      size: json['size'] ?? 'medium',
      createdAt: json['created_at'] ?? '',
    );
  }

  bool get isAvailable => status == 'available';
}

class PackageModel {
  final String id;
  final String senderName;
  final String senderDob;
  final String senderPhone;
  final String receiverName;
  final String receiverPhone;
  final String lockerId;
  final String lockerNumber;
  final String pinCode;
  final String status;
  final String description;
  final double weight;
  final String sentAt;
  final String? receivedAt;

  PackageModel({
    required this.id,
    required this.senderName,
    required this.senderDob,
    required this.senderPhone,
    required this.receiverName,
    required this.receiverPhone,
    required this.lockerId,
    required this.lockerNumber,
    required this.pinCode,
    required this.status,
    required this.description,
    required this.weight,
    required this.sentAt,
    this.receivedAt,
  });

  factory PackageModel.fromJson(Map<String, dynamic> json) {
    return PackageModel(
      id: json['id'] ?? '',
      senderName: json['sender_name'] ?? '',
      senderDob: json['sender_dob'] ?? '',
      senderPhone: json['sender_phone'] ?? '',
      receiverName: json['receiver_name'] ?? '',
      receiverPhone: json['receiver_phone'] ?? '',
      lockerId: json['locker_id'] ?? '',
      lockerNumber: json['locker_number'] ?? '',
      pinCode: json['pin_code'] ?? '',
      status: json['status'] ?? 'stored',
      description: json['description'] ?? '',
      weight: (json['weight'] ?? 0).toDouble(),
      sentAt: json['sent_at'] ?? '',
      receivedAt: json['received_at'],
    );
  }

  bool get isStored => status == 'stored';
}

class StatsModel {
  final int totalLockers;
  final int availableLockers;
  final int packagesStored;
  final int packagesReceived;

  StatsModel({
    required this.totalLockers,
    required this.availableLockers,
    required this.packagesStored,
    required this.packagesReceived,
  });

  factory StatsModel.fromJson(Map<String, dynamic> json) {
    return StatsModel(
      totalLockers: json['total_lockers'] ?? 0,
      availableLockers: json['available_lockers'] ?? 0,
      packagesStored: json['packages_stored'] ?? 0,
      packagesReceived: json['packages_received'] ?? 0,
    );
  }

  int get occupiedLockers => totalLockers - availableLockers;
}
