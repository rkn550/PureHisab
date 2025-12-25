class PartyModel {
  final String id;
  final String businessId;
  final String partyName;

  final String type;
  final String phoneNumber;
  final String? address;
  final String? partiesPhotoUrl;
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
    required this.phoneNumber,
    this.address,
    this.partiesPhotoUrl,
    this.reminderDate,
    this.reminderType,
    this.smsSetting = false,
    this.smsLanguage,
    this.isDeleted = false,
    this.isSynced = false,
    this.firebaseUpdatedAt,
  });

  factory PartyModel.fromMap(Map<String, dynamic> map) {
    return PartyModel(
      id: map['id'],
      businessId: map['business_id'],
      partyName: map['party_name'],
      type: map['type'],
      phoneNumber: map['phone_number'],
      address: map['address'],
      partiesPhotoUrl: map['parties_photo_url'],
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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'business_id': businessId,
      'party_name': partyName,
      'type': type,
      'phone_number': phoneNumber,
      'address': address,
      'parties_photo_url': partiesPhotoUrl,
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

  Map<String, dynamic> toFirebase() {
    return {
      'partyName': partyName,
      'phoneNumber': phoneNumber,
      'address': address,
      'parties_photo_url': partiesPhotoUrl,
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

  PartyModel copyWith({
    String? partyName,
    String? phoneNumber,
    String? address,
    String? partyPhotoUrl,
    String? type,
    int? reminderDate,
    String? reminderType,
    bool? smsSetting,
    String? smsLanguage,
    bool? isDeleted,
    bool? isSynced,
    int? updatedAt,
    int? firebaseUpdatedAt,
    bool clearPartyPhotoUrl = false,
  }) {
    return PartyModel(
      id: id,
      businessId: businessId,
      partyName: partyName ?? this.partyName,
      type: type ?? this.type,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      partiesPhotoUrl: clearPartyPhotoUrl
          ? null
          : (partyPhotoUrl ?? this.partiesPhotoUrl),
      reminderDate: reminderDate ?? this.reminderDate,
      reminderType: reminderType ?? this.reminderType,
      smsSetting: smsSetting ?? this.smsSetting,
      smsLanguage: smsLanguage ?? this.smsLanguage,
      isDeleted: isDeleted ?? this.isDeleted,
      isSynced: isSynced ?? this.isSynced,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      firebaseUpdatedAt: firebaseUpdatedAt ?? this.firebaseUpdatedAt,
    );
  }
}
