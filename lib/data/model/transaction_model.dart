class TransactionModel {
  final String id;
  final String businessId;
  final String partyId;
  final double amount;

  final String direction;
  final int date;
  final String? description;
  final String? transactionPhotoUrl;
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
    this.transactionPhotoUrl,
    this.isDeleted = false,
    this.isSynced = false,
    this.firebaseUpdatedAt,
  });

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      businessId: map['business_id'],
      partyId: map['party_id'],
      amount: (map['amount'] as num).toDouble(),
      direction: map['direction'],
      date: map['date'],
      description: map['description'],
      transactionPhotoUrl: map['transaction_photo_url'],
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
      'party_id': partyId,
      'amount': amount,
      'direction': direction,
      'date': date,
      'description': description,
      'transaction_photo_url': transactionPhotoUrl,
      'is_deleted': isDeleted ? 1 : 0,
      'is_synced': isSynced ? 1 : 0,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'firebase_updated_at': firebaseUpdatedAt,
    };
  }

  Map<String, dynamic> toFirebase() {
    return {
      'amount': amount,
      'direction': direction,
      'date': date,
      'description': description,
      'transactionPhotoUrl': transactionPhotoUrl,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'isDeleted': isDeleted,
    };
  }

  TransactionModel copyWith({
    double? amount,
    String? direction,
    int? date,
    String? description,
    String? transactionPhotoUrl,
    bool? isDeleted,
    bool? isSynced,
    int? updatedAt,
    int? firebaseUpdatedAt,
    bool clearTransactionPhotoUrl = false,
  }) {
    return TransactionModel(
      id: id,
      businessId: businessId,
      partyId: partyId,
      amount: amount ?? this.amount,
      direction: direction ?? this.direction,
      date: date ?? this.date,
      description: description ?? this.description,
      transactionPhotoUrl: clearTransactionPhotoUrl
          ? null
          : (transactionPhotoUrl ?? this.transactionPhotoUrl),
      isDeleted: isDeleted ?? this.isDeleted,
      isSynced: isSynced ?? this.isSynced,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      firebaseUpdatedAt: firebaseUpdatedAt ?? this.firebaseUpdatedAt,
    );
  }
}
