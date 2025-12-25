enum UserRole { user, admin }

class User {
  final String id;
  final String email;
  final String name;
  final double walletBalance;
  final UserRole role;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.email,
    required this.name,
    required this.walletBalance,
    required this.role,
    required this.createdAt,
  });

  bool get isAdmin => role == UserRole.admin;
}