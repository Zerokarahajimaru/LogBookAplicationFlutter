import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_application_1/features/auth/models/user_model.dart';
import 'package:flutter_application_1/features/logbook/models/log_model.dart';
import 'package:logger/logger.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MongoService {
  static final MongoService _instance = MongoService._internal();
  factory MongoService() => _instance;
  MongoService._internal();

  Db? _db;
  final _logger = Logger();

  String get _uri => dotenv.get('MONGODB_URI', fallback: "");
  static const String _logCollectionName = "logs";
  static const String _userCollectionName = "users";

  Future<void> connect() async {
    if (_uri.isEmpty) throw Exception("MONGODB_URI tidak ditemukan di file .env");
    if (_db != null && _db!.isConnected) return;
    try {
      _db = await Db.create(_uri);
      await _db!.open();
      _logger.i("Koneksi ke MongoDB berhasil.");
    } catch (e) {
      _logger.e("Gagal menyambung ke MongoDB: $e");
      rethrow;
    }
  }

  Future<void> close() async {
    if (_db != null && _db!.isConnected) {
      await _db!.close();
      _db = null;
    }
  }

  // --- User Management ---

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<UserModel?> getUserByUid(String uid) async {
    if (_db == null || !_db!.isConnected) await connect();
    try {
      final collection = _db!.collection(_userCollectionName);
      final userMap = await collection.findOne(where.eq('uid', uid));
      if (userMap != null) {
        return UserModel.fromMap(userMap);
      }
      return null;
    } catch (e) {
      _logger.e("Gagal mendapatkan user: $e");
      return null;
    }
  }

  Future<bool> verifyPassword(String uid, String password) async {
    final user = await getUserByUid(uid);
    if (user == null) return false;
    final hashedPassword = _hashPassword(password);
    return user.password == hashedPassword;
  }

  Future<WriteResult> createUser(UserModel user) async {
    if (_db == null || !_db!.isConnected) await connect();
    
    final collection = _db!.collection(_userCollectionName);
    final existingUser = await collection.findOne(where.eq('uid', user.uid));
    if (existingUser != null) {
      throw Exception('User dengan UID ${user.uid} sudah ada.');
    }
    
    final hashedPassword = _hashPassword(user.password);
    final userToInsert = UserModel(
      uid: user.uid,
      password: hashedPassword,
      teamId: user.teamId,
      role: user.role,
    );

    try {
      final result = await collection.insertOne(userToInsert.toMap());
      _logger.i("User baru berhasil dibuat: ${user.uid}");
      return result;
    } catch (e) {
      _logger.e("Gagal membuat user: $e");
      rethrow;
    }
  }

  // --- Log Management ---

  Future<List<Map<String, dynamic>>> getLogs(String teamId) async {
    if (_db == null || !_db!.isConnected) await connect();
    try {
      final collection = _db!.collection(_logCollectionName);
      final logs = await collection.find(where.eq('teamId', teamId).sortBy('date', descending: true)).toList();
      _logger.i("Fetched ${logs.length} logs for team $teamId.");
      return logs;
    } catch (e) {
      _logger.e("Gagal mengambil logs: $e");
      return [];
    }
  }

  Future<void> upsertLog(LogModel log, {required Map<String, dynamic> currentUser}) async {
    if (_db == null || !_db!.isConnected) await connect();
    
    final userRole = currentUser['role'];
    final userUid = currentUser['uid'];

    try {
      final collection = _db!.collection(_logCollectionName);
      final objectId = log.id != null ? ObjectId.fromHexString(log.id!) : null;

      // If objectId is not null, it's an update. We must verify ownership.
      if (objectId != null) {
        final existingLog = await collection.findOne(where.eq('_id', objectId));
        if (existingLog != null) {
          final logAuthorId = existingLog['authorId'];
          // RBAC Check for UPDATE
          if (userRole != 'Ketua' && (userRole == 'Anggota' && logAuthorId != userUid)) {
            throw Exception("Hak akses ditolak: Anda tidak dapat mengubah log milik pengguna lain.");
          }
        }
      } else {
        // This is an INSERT. Ensure the authorId in the new log matches the current user.
        if (log.authorId != userUid) {
          throw Exception("Hak akses ditolak: Anda tidak dapat membuat log atas nama pengguna lain.");
        }
      }

      // If all checks pass, proceed with upsert
      await collection.updateOne(
        where.eq('_id', objectId),
        modify.set('title', log.title)
              .set('description', log.description)
              .set('date', log.date)
              .set('authorId', log.authorId)
              .set('teamId', log.teamId)
              .set('isPublic', log.isPublic)
              .set('category', log.category),
        upsert: true,
      );
      _logger.i("Upserted log: ${log.title}");
    } catch (e) {
      _logger.e("Failed to upsert log: $e");
      rethrow;
    }
  }

  Future<void> deleteLog(LogModel log, {required Map<String, dynamic> currentUser}) async {
    if (_db == null || !_db!.isConnected) await connect();
    try {
      final collection = _db!.collection(_logCollectionName);
      final objectId = ObjectId.fromHexString(log.id!);

      // Fetch the log first to check for authorship
      final existingLog = await collection.findOne(where.eq('_id', objectId));
      if (existingLog == null) {
        throw Exception("Log tidak ditemukan untuk dihapus.");
      }

      final userRole = currentUser['role'];
      final userUid = currentUser['uid'];
      final logAuthorId = existingLog['authorId'];

      // RBAC Check
      if (userRole == 'Ketua' || (userRole == 'Anggota' && logAuthorId == userUid)) {
        await collection.deleteOne(where.eq('_id', objectId));
        _logger.i("Deleted log: ${log.title}");
      } else {
        throw Exception("Hak akses ditolak: Anda tidak dapat menghapus log milik pengguna lain.");
      }
    } catch (e) {
      _logger.e("Failed to delete log: $e");
      rethrow;
    }
  }
}