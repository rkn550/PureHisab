class PartyModel {
  final String id;
  final String businessId;
  final String partyName;
  final String? phoneNumber;
  final String? address;
  final String? photoUrl;

  /// customer | supplier
  final String type;

  final int? reminderDate;
  final String? reminderType;

  final bool smsSetting;
  final String? smsLanguage;

  final bool isDeleted;
  final bool isSynced;

  final int createdAt;
  final int updatedAt;
  final int? firebaseUpdatedAt;

  PartyModel({
    required this.id,
    required this.businessId,
    required this.partyName,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
    this.phoneNumber,
    this.address,
    this.photoUrl,
    this.reminderDate,
    this.reminderType,
    this.smsSetting = false,
    this.smsLanguage,
    this.isDeleted = false,
    this.isSynced = false,
    this.firebaseUpdatedAt,
  });

  /// SQLite → Object
  factory PartyModel.fromMap(Map<String, dynamic> map) {
    return PartyModel(
      id: map['id'],
      businessId: map['business_id'],
      partyName: map['party_name'],
      phoneNumber: map['phone_number'],
      address: map['address'],
      photoUrl: map['photo_url'],
      type: map['type'],
      reminderDate: map['reminder_date'],
      reminderType: map['reminder_type'],
      smsSetting: map['sms_setting'] == 1,
      smsLanguage: map['sms_language'],
      isDeleted: map['is_deleted'] == 1,
      isSynced: map['is_synced'] == 1,
      createdAt: map['created_at'],
      updatedAt: map['updated_at'],
      firebaseUpdatedAt: map['firebase_updated_at'],
    );
  }

  /// Object → SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'business_id': businessId,
      'party_name': partyName,
      'phone_number': phoneNumber,
      'address': address,
      'photo_url': photoUrl,
      'type': type,
      'reminder_date': reminderDate,
      'reminder_type': reminderType,
      'sms_setting': smsSetting ? 1 : 0,
      'sms_language': smsLanguage,
      'is_deleted': isDeleted ? 1 : 0,
      'is_synced': isSynced ? 1 : 0,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'firebase_updated_at': firebaseUpdatedAt,
    };
  }

  /// Object → Firebase
  Map<String, dynamic> toFirebase() {
    return {
      'partyName': partyName,
      'phoneNumber': phoneNumber,
      'address': address,
      'photoUrl': photoUrl,
      'type': type,
      'reminderDate': reminderDate,
      'reminderType': reminderType,
      'smsSetting': smsSetting,
      'smsLanguage': smsLanguage,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'isDeleted': isDeleted,
    };
  }
}
