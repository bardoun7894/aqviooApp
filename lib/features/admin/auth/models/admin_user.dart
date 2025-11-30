import 'package:cloud_firestore/cloud_firestore.dart';

class AdminUser {
  final String id;
  final String email;
  final String displayName;
  final AdminRole role;
  final AdminPermissions permissions;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  const AdminUser({
    required this.id,
    required this.email,
    required this.displayName,
    required this.role,
    required this.permissions,
    required this.createdAt,
    this.lastLoginAt,
  });

  factory AdminUser.fromMap(Map<String, dynamic> map) {
    return AdminUser(
      id: map['id'] as String,
      email: map['email'] as String,
      displayName: map['displayName'] as String,
      role: AdminRole.values.firstWhere(
        (r) => r.name == map['role'],
        orElse: () => AdminRole.admin,
      ),
      permissions: AdminPermissions.fromMap(map['permissions'] as Map<String, dynamic>),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      lastLoginAt: map['lastLoginAt'] != null
          ? (map['lastLoginAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'role': role.name,
      'permissions': permissions.toMap(),
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLoginAt': lastLoginAt != null ? Timestamp.fromDate(lastLoginAt!) : null,
    };
  }

  AdminUser copyWith({
    String? id,
    String? email,
    String? displayName,
    AdminRole? role,
    AdminPermissions? permissions,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return AdminUser(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      permissions: permissions ?? this.permissions,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }
}

enum AdminRole {
  superAdmin,
  admin,
  moderator,
  support,
}

class AdminPermissions {
  final bool canManageUsers;
  final bool canAdjustCredits;
  final bool canModerateContent;
  final bool canViewPayments;
  final bool canManageAdmins;
  final bool canConfigureSettings;

  const AdminPermissions({
    required this.canManageUsers,
    required this.canAdjustCredits,
    required this.canModerateContent,
    required this.canViewPayments,
    required this.canManageAdmins,
    required this.canConfigureSettings,
  });

  factory AdminPermissions.fromMap(Map<String, dynamic> map) {
    return AdminPermissions(
      canManageUsers: map['canManageUsers'] as bool? ?? false,
      canAdjustCredits: map['canAdjustCredits'] as bool? ?? false,
      canModerateContent: map['canModerateContent'] as bool? ?? false,
      canViewPayments: map['canViewPayments'] as bool? ?? false,
      canManageAdmins: map['canManageAdmins'] as bool? ?? false,
      canConfigureSettings: map['canConfigureSettings'] as bool? ?? false,
    );
  }

  factory AdminPermissions.superAdmin() {
    return const AdminPermissions(
      canManageUsers: true,
      canAdjustCredits: true,
      canModerateContent: true,
      canViewPayments: true,
      canManageAdmins: true,
      canConfigureSettings: true,
    );
  }

  factory AdminPermissions.admin() {
    return const AdminPermissions(
      canManageUsers: true,
      canAdjustCredits: true,
      canModerateContent: true,
      canViewPayments: true,
      canManageAdmins: false,
      canConfigureSettings: false,
    );
  }

  factory AdminPermissions.moderator() {
    return const AdminPermissions(
      canManageUsers: false,
      canAdjustCredits: false,
      canModerateContent: true,
      canViewPayments: false,
      canManageAdmins: false,
      canConfigureSettings: false,
    );
  }

  factory AdminPermissions.support() {
    return const AdminPermissions(
      canManageUsers: true,
      canAdjustCredits: true,
      canModerateContent: false,
      canViewPayments: false,
      canManageAdmins: false,
      canConfigureSettings: false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'canManageUsers': canManageUsers,
      'canAdjustCredits': canAdjustCredits,
      'canModerateContent': canModerateContent,
      'canViewPayments': canViewPayments,
      'canManageAdmins': canManageAdmins,
      'canConfigureSettings': canConfigureSettings,
    };
  }
}
