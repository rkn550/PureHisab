import 'package:purehisab/data/local/local_db.dart';
import 'package:purehisab/data/model/party_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

class PartyRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Uuid _uuid = const Uuid();

  Future<PartyModel> createParty({
    required String businessId,
    required String partyName,
    required String type,
    String? phoneNumber,
    String? address,
    String? photoUrl,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated. Please login first.');
      }

      final db = await _dbHelper.database;
      final now = DateTime.now().millisecondsSinceEpoch;

      final party = PartyModel(
        id: _uuid.v4(),
        businessId: businessId,
        partyName: partyName,
        type: type,
        phoneNumber: phoneNumber,
        address: address,
        photoUrl: photoUrl,
        createdAt: now,
        updatedAt: now,
      );

      await db.insert(
        'parties',
        party.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      final savedParty = await getPartyById(party.id);
      if (savedParty == null) {
        throw Exception('Party was not saved to database');
      }

      return savedParty;
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Failed to create party: $e');
    }
  }

  Future<List<PartyModel>> getPartiesByBusiness(String businessId) async {
    final db = await _dbHelper.database;

    final result = await db.query(
      'parties',
      where: 'business_id = ? AND is_deleted = 0',
      whereArgs: [businessId],
      orderBy: 'created_at DESC',
    );

    return result.map(PartyModel.fromMap).toList();
  }

  Future<List<PartyModel>> getPartiesByType(
    String businessId,
    String type,
  ) async {
    final db = await _dbHelper.database;

    final result = await db.query(
      'parties',
      where: 'business_id = ? AND type = ? AND is_deleted = 0',
      whereArgs: [businessId, type],
      orderBy: 'created_at DESC',
    );

    return result.map(PartyModel.fromMap).toList();
  }

  Future<PartyModel?> getPartyById(String partyId) async {
    final db = await _dbHelper.database;

    final result = await db.query(
      'parties',
      where: 'id = ? AND is_deleted = 0',
      whereArgs: [partyId],
      limit: 1,
    );

    if (result.isEmpty) return null;
    return PartyModel.fromMap(result.first);
  }

  Future<void> updateParty(PartyModel party) async {
    final db = await _dbHelper.database;

    await db.update(
      'parties',
      party
          .copyWith(
            updatedAt: DateTime.now().millisecondsSinceEpoch,
            isSynced: false,
          )
          .toMap(),
      where: 'id = ?',
      whereArgs: [party.id],
    );
  }

  Future<void> deleteParty(String partyId) async {
    final db = await _dbHelper.database;

    await db.update(
      'parties',
      {
        'is_deleted': 1,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
        'is_synced': 0,
      },
      where: 'id = ?',
      whereArgs: [partyId],
    );
  }
}

extension PartyModelCopyWith on PartyModel {
  PartyModel copyWith({
    String? partyName,
    String? phoneNumber,
    String? address,
    String? photoUrl,
    String? type,
    int? reminderDate,
    String? reminderType,
    bool? smsSetting,
    String? smsLanguage,
    bool? isDeleted,
    bool? isSynced,
    int? updatedAt,
    int? firebaseUpdatedAt,
    bool clearPhotoUrl = false,
  }) {
    return PartyModel(
      id: id,
      businessId: businessId,
      partyName: partyName ?? this.partyName,
      type: type ?? this.type,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      photoUrl: clearPhotoUrl ? null : (photoUrl ?? this.photoUrl),
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
