import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../local/local_db.dart';
import '../model/business_model.dart';
import '../services/session_service.dart';

class BusinessRepository extends GetxService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final SessionService _sessionService = Get.find<SessionService>();
  final Uuid _uuid = const Uuid();

  String get _userId {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('User not authenticated');
    }
    return user.uid;
  }

  Future<void> createBusiness({required String businessName}) async {
    final db = await _dbHelper.database;
    final now = DateTime.now().millisecondsSinceEpoch;
    final user = await _sessionService.getSession();
    final business = BusinessModel(
      id: _uuid.v4(),
      businessName: businessName.trim(),
      ownerName: user?.name ?? '',
      phoneNumber: user?.phoneNumber ?? '',
      userId: _userId,
      createdAt: now,
      updatedAt: now,
      isSynced: false,
    );

    try {
      await db.transaction((txn) async {
        await txn.insert(
          'businesses',
          business.toMap(),
          conflictAlgorithm: ConflictAlgorithm.abort,
        );
      });
    } on DatabaseException catch (e) {
      throw Exception(
        'Database error while creating business: ${e.toString()}',
      );
    } catch (e) {
      throw Exception('Failed to create business: ${e.toString()}');
    }
  }

  Future<List<BusinessModel>> getBusinesses() async {
    final db = await _dbHelper.database;

    final result = await db.query(
      'businesses',
      where: 'user_id = ? AND is_deleted = 0',
      whereArgs: [_userId],
      orderBy: 'created_at DESC',
    );

    return result.map(BusinessModel.fromMap).toList();
  }

  Future<BusinessModel?> getBusinessById(String businessId) async {
    final db = await _dbHelper.database;

    final result = await db.query(
      'businesses',
      where: 'id = ? AND is_deleted = 0',
      whereArgs: [businessId],
      limit: 1,
    );

    return result.isEmpty ? null : BusinessModel.fromMap(result.first);
  }

  Future<void> updateBusiness(BusinessModel business) async {
    final db = await _dbHelper.database;

    final data = business
        .copyWith(
          updatedAt: DateTime.now().millisecondsSinceEpoch,
          isSynced: false,
        )
        .toMap();

    await db.transaction((txn) async {
      await txn.update(
        'businesses',
        data,
        where: 'id = ?',
        whereArgs: [business.id],
      );
    });
  }

  Future<void> deleteBusiness(String businessId) async {
    final db = await _dbHelper.database;

    await db.transaction((txn) async {
      await txn.update(
        'businesses',
        {
          'is_deleted': 1,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
          'is_synced': 0,
        },
        where: 'id = ?',
        whereArgs: [businessId],
      );
    });
  }

  Future<List<BusinessModel>> getUnsyncedBusinesses() async {
    final db = await _dbHelper.database;

    final result = await db.query(
      'businesses',
      where: 'is_synced = 0 AND is_deleted = 0',
    );

    return result.map(BusinessModel.fromMap).toList();
  }

  Future<void> markAsSynced({
    required String businessId,
    required int firebaseUpdatedAt,
  }) async {
    final db = await _dbHelper.database;

    await db.transaction((txn) async {
      await txn.update(
        'businesses',
        {'is_synced': 1, 'firebase_updated_at': firebaseUpdatedAt},
        where: 'id = ?',
        whereArgs: [businessId],
      );
    });
  }

  Future<List<Map<String, dynamic>>> dumpAll() async {
    final db = await _dbHelper.database;
    return db.query('businesses');
  }
}
