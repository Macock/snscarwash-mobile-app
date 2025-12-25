import '../../domain/entities/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel extends User {
  const UserModel({
    required String id,
    required String email,
    required String name,
    required double walletBalance,
    required UserRole role,
    required DateTime createdAt,
  }) : super(
          id: id,
          email: email,
          name: name,
          walletBalance: walletBalance,
          role: role,
          createdAt: createdAt,
        );

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      walletBalance: (data['walletBalance'] ?? 0).toDouble(),
      role: data['role'] == 'admin' ? UserRole.admin : UserRole.user,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      'walletBalance': walletBalance,
      'role': role == UserRole.admin ? 'admin' : 'user',
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}