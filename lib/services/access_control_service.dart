import 'package:flutter_dotenv/flutter_dotenv.dart';

class AccessControlService {
  // --- ROLES ---
  // Fetches roles from .env, defaulting to 'Anggota'.
  static List<String> get availableRoles =>
      dotenv.env['APP_ROLES']?.split(',') ?? ['Anggota'];
  static const String roleKetua = 'Ketua';
  static const String roleAnggota = 'Anggota';

  // --- ACTIONS ---
  static const String actionCreate = 'create';
  static const String actionRead = 'read';
  static const String actionUpdate = 'update';
  static const String actionDelete = 'delete';

  // --- PERMISSION MATRIX ---
  // Centralized, flexible permission management.
  static final Map<String, List<String>> _rolePermissions = {
    roleKetua: [actionCreate, actionRead, actionUpdate, actionDelete],
    roleAnggota: [actionCreate, actionRead], // Anggota can only Create and Read
  };

  /// Determines if a user can perform a specific action on a resource.
  ///
  /// This is the "Gatekeeper". It checks permissions based on role and ownership.
  ///
  /// [role]: The role of the user (e.g., 'Ketua', 'Anggota').
  /// [action]: The action to be performed (e.g., 'update', 'delete').
  /// [isOwner]: Whether the user is the original author of the log.
  ///
  /// As per Task 5 (Sovereignty), editing/deleting is an owner-only right.
  /// As per Task 3 (RBAC), 'Ketua' has broader permissions but is restricted
  /// by the sovereignty rule.
  static bool canPerform(String role, String action, {required bool isOwner}) {
    // Rule for Sovereignty (Task 5): Only the owner can edit or delete.
    if (action == actionUpdate || action == actionDelete) {
      return isOwner;
    }

    // General role-based permissions for other actions (Create, Read).
    final permissions = _rolePermissions[role] ?? [];
    return permissions.contains(action);
  }
}
