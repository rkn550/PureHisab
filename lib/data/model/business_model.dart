class BusinessModel {
  final String id;
  final String businessName;
  final String userId;
  final String? ownerName;
  final String? phoneNumber;
  final String? photoUrl;
  final bool isDeleted;
  final bool isSynced;
  final int createdAt;
  final int updatedAt;
  final int? firebaseUpdatedAt;

  BusinessModel({
    required this.id,
    required this.businessName,
    required this.userId,
    this.ownerName,
    this.phoneNumber,
    this.photoUrl,
    this.isDeleted = false,
    this.isSynced = false,
    required this.createdAt,
    required this.updatedAt,
    this.firebaseUpdatedAt,
  });

  /// SQLite → Object
  factory BusinessModel.fromMap(Map<String, dynamic> map) {
    return BusinessModel(
      id: map['id'],
      businessName: map['business_name'],
      userId: map['user_id'],
      ownerName: map['owner_name'],
      phoneNumber: map['phone_number'],
      photoUrl: map['photo_url'],
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
      'business_name': businessName,
      'owner_name': ownerName,
      'phone_number': phoneNumber,
      'photo_url': photoUrl,
      'is_deleted': isDeleted ? 1 : 0,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'user_id': userId,
      'is_synced': isSynced ? 1 : 0,
      'firebase_updated_at': firebaseUpdatedAt,
    };
  }

  /// Object → Firebase
  Map<String, dynamic> toFirebase() {
    return {
      'businessName': businessName,
      'ownerName': ownerName,
      'phoneNumber': phoneNumber,
      'photoUrl': photoUrl,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'isDeleted': isDeleted,
    };
  }

  BusinessModel copyWith({
    String? businessName,
    String? ownerName,
    String? phoneNumber,
    String? photoUrl,
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
      photoUrl: photoUrl ?? this.photoUrl,
      isDeleted: isDeleted ?? this.isDeleted,
      isSynced: isSynced ?? this.isSynced,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      firebaseUpdatedAt: firebaseUpdatedAt ?? this.firebaseUpdatedAt,
    );
  }
}
