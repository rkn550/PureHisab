class TransactionModel {
  final String id;
  final String businessId;
  final String partyId;

  final double amount;

  /// gave | got
  final String direction;

  final int date;
  final String? description;
  final String? photoUrl;

  final bool isDeleted;
  final bool isSynced;

  final int createdAt;
  final int updatedAt;
  final int? firebaseUpdatedAt;

  TransactionModel({
    required this.id,
    required this.businessId,
    required this.partyId,
    required this.amount,
    required this.direction,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
    this.description,
    this.photoUrl,
    this.isDeleted = false,
    this.isSynced = false,
    this.firebaseUpdatedAt,
  });

  /// SQLite → Object
  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      businessId: map['business_id'],
      partyId: map['party_id'],
      amount: (map['amount'] as num).toDouble(),
      direction: map['direction'],
      date: map['date'],
      description: map['description'],
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
      'business_id': businessId,
      'party_id': partyId,
      'amount': amount,
      'direction': direction,
      'date': date,
      'description': description,
      'photo_url': photoUrl,
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
      'amount': amount,
      'direction': direction,
      'date': date,
      'description': description,
      'photoUrl': photoUrl,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'isDeleted': isDeleted,
    };
  }
}
