import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoURL;
  final String role; // 'user' | 'admin'
  final bool emailVerified;
  final String? phone;
  final int totalOrders;
  final double totalSpent;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final String? dob;
  final String? gender;
  final String? bio;

  const UserProfile({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoURL,
    required this.role,
    required this.emailVerified,
    this.phone,
    this.totalOrders = 0,
    this.totalSpent = 0,
    required this.createdAt,
    this.lastLoginAt,
    this.dob,
    this.gender,
    this.bio,
  });

  bool get isAdmin => role == 'admin';

  String get initials {
    if (displayName != null && displayName!.trim().isNotEmpty) {
      final parts = displayName!.trim().split(' ').where((p) => p.isNotEmpty).toList();
      if (parts.isNotEmpty) {
        if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
        return parts[0][0].toUpperCase();
      }
    }
    if (email.isNotEmpty) return email[0].toUpperCase();
    return '?';
  }

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return UserProfile(
      uid: doc.id,
      email: d['email'] as String? ?? '',
      displayName: d['displayName'] as String?,
      photoURL: d['photoURL'] as String?,
      role: d['role'] as String? ?? 'user',
      emailVerified: d['emailVerified'] as bool? ?? false,
      phone: d['phone'] as String?,
      totalOrders: (d['totalOrders'] as num?)?.toInt() ?? 0,
      totalSpent: (d['totalSpent'] as num?)?.toDouble() ?? 0,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLoginAt: (d['lastLoginAt'] as Timestamp?)?.toDate(),
      dob: d['dob'] as String?,
      gender: d['gender'] as String?,
      bio: d['bio'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'email': email,
    if (displayName != null) 'displayName': displayName,
    if (photoURL != null) 'photoURL': photoURL,
    'role': role,
    'emailVerified': emailVerified,
    if (phone != null) 'phone': phone,
    'totalOrders': totalOrders,
    'totalSpent': totalSpent,
  };

  UserProfile copyWith({
    String? displayName,
    String? photoURL,
    String? phone,
    String? dob,
    String? gender,
    String? bio,
  }) => UserProfile(
    uid: uid,
    email: email,
    displayName: displayName ?? this.displayName,
    photoURL: photoURL ?? this.photoURL,
    role: role,
    emailVerified: emailVerified,
    phone: phone ?? this.phone,
    totalOrders: totalOrders,
    totalSpent: totalSpent,
    createdAt: createdAt,
    lastLoginAt: lastLoginAt,
    dob: dob ?? this.dob,
    gender: gender ?? this.gender,
    bio: bio ?? this.bio,
  );
}
