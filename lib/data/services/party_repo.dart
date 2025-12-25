import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../local/local_db.dart';
import '../model/party_model.dart';

class PartyRepository extends GetxService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final Uuid _uuid = const Uuid();

  Future<PartyModel> createParty({
    required String businessId,
    required String partyName,
    required String type,
    required String phoneNumber,
    String? address,
    String? partiesPhotoUrl,
  }) async {
    try {
      final db = await _dbHelper.database;
      final now = DateTime.now().millisecondsSinceEpoch;

      final party = PartyModel(
        id: _uuid.v4(),
        businessId: businessId,
        partyName: partyName,
        type: type,
        phoneNumber: phoneNumber,
        address: address,
        partiesPhotoUrl: partiesPhotoUrl,
        createdAt: now,
        updatedAt: now,
        isSynced: false,
      );

      await db.transaction((txn) async {
        await txn.insert(
          'parties',
          party.toMap(),
          conflictAlgorithm: ConflictAlgorithm.abort,
        );
      });
      return party;
    } catch (e) {
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

  Future<List<PartyModel>> getPartiesByType({
    required String businessId,
    required String type,
  }) async {
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

    return result.isEmpty ? null : PartyModel.fromMap(result.first);
  }

  Future<void> updateParty(PartyModel party) async {
    final db = await _dbHelper.database;

    final data = party
        .copyWith(
          updatedAt: DateTime.now().millisecondsSinceEpoch,
          isSynced: false,
        )
        .toMap();

    await db.transaction((txn) async {
      await txn.update('parties', data, where: 'id = ?', whereArgs: [party.id]);
    });
  }

  Future<void> deleteParty(String partyId) async {
    final db = await _dbHelper.database;

    await db.transaction((txn) async {
      await txn.update(
        'parties',
        {
          'is_deleted': 1,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
          'is_synced': 0,
        },
        where: 'id = ?',
        whereArgs: [partyId],
      );
    });
  }
}
