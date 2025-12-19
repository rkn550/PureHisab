import 'package:purehisab/data/local/local_db.dart';
import 'package:purehisab/data/model/business_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

class BusinessRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Uuid _uuid = const Uuid();

  Future<BusinessModel> createBusiness({
    required String businessName,
    String? ownerName,
    String? photoUrl,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated. Please login first.');
      }

      final db = await _dbHelper.database;
      final now = DateTime.now().millisecondsSinceEpoch;
      final phoneNumber = currentUser.phoneNumber ?? '';

      final business = BusinessModel(
        id: _uuid.v4(),
        businessName: businessName,
        ownerName: ownerName,
        phoneNumber: phoneNumber,
        photoUrl: photoUrl,
        userId: currentUser.uid,
        isDeleted: false,
        createdAt: now,
        updatedAt: now,
        isSynced: false,
        firebaseUpdatedAt: null,
      );

      await db.insert(
        'businesses',
        business.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      final savedBusiness = await getBusinessById(business.id);
      if (savedBusiness == null) {
        throw Exception('Business was not saved to database');
      }
      return savedBusiness;
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Failed to create business: $e');
    }
  }

  Future<List<BusinessModel>> getBusinesses() async {
    final db = await _dbHelper.database;
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('User not authenticated. Please login first.');
    }
    final uid = currentUser.uid;

    final result = await db.query(
      'businesses',
      where: 'user_id = ? AND is_deleted = 0',
      whereArgs: [uid],
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

    if (result.isEmpty) return null;
    return BusinessModel.fromMap(result.first);
  }

  Future<void> updateBusiness(BusinessModel business) async {
    final db = await _dbHelper.database;

    final updateData = business
        .copyWith(
          updatedAt: DateTime.now().millisecondsSinceEpoch,
          isSynced: false,
        )
        .toMap();

    await db.update(
      'businesses',
      updateData,
      where: 'id = ?',
      whereArgs: [business.id],
    );
  }

  Future<void> deleteBusiness(String businessId) async {
    final db = await _dbHelper.database;

    await db.update(
      'businesses',
      {
        'is_deleted': 1,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
        'is_synced': 0,
      },
      where: 'id = ?',
      whereArgs: [businessId],
    );
  }

  Future<List<BusinessModel>> getUnsyncedBusinesses() async {
    final db = await _dbHelper.database;

    final result = await db.query('businesses', where: 'is_synced = 0');

    return result.map(BusinessModel.fromMap).toList();
  }

  Future<void> markAsSynced({
    required String businessId,
    required int firebaseUpdatedAt,
  }) async {
    final db = await _dbHelper.database;

    await db.update(
      'businesses',
      {'is_synced': 1, 'firebase_updated_at': firebaseUpdatedAt},
      where: 'id = ?',
      whereArgs: [businessId],
    );
  }

  Future<List<Map<String, dynamic>>> getAllBusinessesDebug() async {
    final db = await _dbHelper.database;
    return await db.query('businesses');
  }
}
