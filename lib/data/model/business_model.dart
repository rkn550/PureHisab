class BusinessModel {
  final String id;
  final String businessName;
  final String userId;
  final String? ownerName;
  final String? phoneNumber;
  final String? businessPhotoUrl;
  final bool isDeleted;
  final bool isSynced;
  final int createdAt;
  final int updatedAt;
  final int? firebaseUpdatedAt;

  BusinessModel({
    required this.id,
    required this.businessName,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    this.ownerName,
    this.phoneNumber,
    this.businessPhotoUrl,
    this.isDeleted = false,
    this.isSynced = false,
    this.firebaseUpdatedAt,
  });

  factory BusinessModel.fromMap(Map<String, dynamic> map) {
    return BusinessModel(
      id: map['id'],
      businessName: map['business_name'],
      userId: map['user_id'],
      ownerName: map['owner_name'],
      phoneNumber: map['phone_number'],
      businessPhotoUrl: map['business_photo_url'],
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
      'business_name': businessName,
      'user_id': userId,
      'owner_name': ownerName,
      'phone_number': phoneNumber,
      'business_photo_url': businessPhotoUrl,
      'is_deleted': isDeleted ? 1 : 0,
      'is_synced': isSynced ? 1 : 0,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'firebase_updated_at': firebaseUpdatedAt,
    };
  }

  Map<String, dynamic> toFirebase() {
    return {
      'businessName': businessName,
      'ownerName': ownerName,
      'phoneNumber': phoneNumber,
      'photoUrl': businessPhotoUrl,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'isDeleted': isDeleted,
    };
  }

  BusinessModel copyWith({
    String? businessName,
    String? ownerName,
    String? phoneNumber,
    String? businessPhotoUrl,
    bool? isDeleted,
    bool? isSynced,
    int? updatedAt,
    int? firebaseUpdatedAt,
  }) {
    return BusinessModel(
      id: id,
      businessName: businessName ?? this.businessName,
      userId: userId,
      ownerName: ownerName ?? this.ownerName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      businessPhotoUrl: businessPhotoUrl ?? this.businessPhotoUrl,
      isDeleted: isDeleted ?? this.isDeleted,
      isSynced: isSynced ?? this.isSynced,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      firebaseUpdatedAt: firebaseUpdatedAt ?? this.firebaseUpdatedAt,
    );
  }
}
