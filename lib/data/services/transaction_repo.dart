import 'package:get/get.dart';
import 'package:purehisab/data/local/local_db.dart';
import 'package:purehisab/data/model/transaction_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

class TransactionRepository extends GetxService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Uuid _uuid = const Uuid();

  Future<TransactionModel> createTransaction({
    required String businessId,
    required String partyId,
    required double amount,
    required String direction,
    required int date,
    String? description,
    String? photoUrl,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated. Please login first.');
      }

      final db = await _dbHelper.database;
      final now = DateTime.now().millisecondsSinceEpoch;

      final transaction = TransactionModel(
        id: _uuid.v4(),
        businessId: businessId,
        partyId: partyId,
        amount: amount,
        direction: direction,
        date: date,
        description: description,
        photoUrl: photoUrl,
        createdAt: now,
        updatedAt: now,
      );

      await db.insert(
        'transactions',
        transaction.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      final savedTransaction = await getTransactionById(transaction.id);
      if (savedTransaction == null) {
        throw Exception('Transaction was not saved to database');
      }

      return savedTransaction;
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Failed to create transaction: $e');
    }
  }

  Future<List<TransactionModel>> getTransactionsByParty(String partyId) async {
    final db = await _dbHelper.database;

    final result = await db.query(
      'transactions',
      where: 'party_id = ? AND is_deleted = 0',
      whereArgs: [partyId],
      orderBy: 'date DESC, created_at DESC',
    );

    return result.map(TransactionModel.fromMap).toList();
  }

  Future<List<TransactionModel>> getTransactionsByBusiness(
    String businessId,
  ) async {
    final db = await _dbHelper.database;

    final result = await db.query(
      'transactions',
      where: 'business_id = ? AND is_deleted = 0',
      whereArgs: [businessId],
      orderBy: 'date DESC, created_at DESC',
    );

    return result.map(TransactionModel.fromMap).toList();
  }

  Future<TransactionModel?> getTransactionById(String transactionId) async {
    final db = await _dbHelper.database;

    final result = await db.query(
      'transactions',
      where: 'id = ? AND is_deleted = 0',
      whereArgs: [transactionId],
      limit: 1,
    );

    if (result.isEmpty) return null;
    return TransactionModel.fromMap(result.first);
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    final db = await _dbHelper.database;

    await db.update(
      'transactions',
      transaction
          .copyWith(
            updatedAt: DateTime.now().millisecondsSinceEpoch,
            isSynced: false,
          )
          .toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<void> deleteTransaction(String transactionId) async {
    final db = await _dbHelper.database;

    await db.update(
      'transactions',
      {
        'is_deleted': 1,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
        'is_synced': 0,
      },
      where: 'id = ?',
      whereArgs: [transactionId],
    );
  }
}

extension TransactionModelCopyWith on TransactionModel {
  TransactionModel copyWith({
    double? amount,
    String? direction,
    int? date,
    String? description,
    String? photoUrl,
    bool? isDeleted,
    bool? isSynced,
    int? updatedAt,
    int? firebaseUpdatedAt,
  }) {
    return TransactionModel(
      id: id,
      businessId: businessId,
      partyId: partyId,
      amount: amount ?? this.amount,
      direction: direction ?? this.direction,
      date: date ?? this.date,
      description: description ?? this.description,
      photoUrl: photoUrl ?? this.photoUrl,
      isDeleted: isDeleted ?? this.isDeleted,
      isSynced: isSynced ?? this.isSynced,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      firebaseUpdatedAt: firebaseUpdatedAt ?? this.firebaseUpdatedAt,
    );
  }
}
