import 'package:flutter_application_1/features/auth/models/user_model.dart';
import 'package:flutter_application_1/services/mongo_service.dart';

class RegistrationController {
  final MongoService _mongoService = MongoService();

  Future<void> registerUser({
    required String uid,
    required String password,
    required String teamId,
  }) async {
    // Basic validation
    if (uid.isEmpty || password.isEmpty || teamId.isEmpty) {
      throw Exception('Semua field harus diisi.');
    }

    try {
      final newUser = UserModel(
        uid: uid,
        password: password, // Password will be hashed by MongoService
        teamId: teamId,
        role: 'anggota', // Default role for new registrations
      );

      await _mongoService.createUser(newUser);
    } catch (e) {
      // Re-throw the exception to be caught by the UI
      rethrow;
    }
  }
}
