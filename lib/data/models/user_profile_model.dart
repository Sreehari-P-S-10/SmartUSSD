class UserProfileModel {
  final String name;
  final String phone;
  final String? upiId;
  final String? bank;
  final String? avatarPath;
  final bool isVerified;

  const UserProfileModel({
    required this.name,
    required this.phone,
    this.upiId,
    this.bank,
    this.avatarPath,
    this.isVerified = false,
  });

  factory UserProfileModel.fromMap(Map<String, dynamic> map) {
    return UserProfileModel(
      name: map['name'] as String? ?? 'User',
      phone: map['phone'] as String? ?? '',
      upiId: map['upi_id'] as String?,
      bank: map['bank'] as String?,
      avatarPath: map['avatar_path'] as String?,
      isVerified: (map['is_verified'] as int? ?? 0) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'upi_id': upiId,
      'bank': bank,
      'avatar_path': avatarPath,
      'is_verified': isVerified ? 1 : 0,
    };
  }

  UserProfileModel copyWith({
    String? name,
    String? phone,
    String? upiId,
    String? bank,
    String? avatarPath,
    bool? isVerified,
  }) {
    return UserProfileModel(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      upiId: upiId ?? this.upiId,
      bank: bank ?? this.bank,
      avatarPath: avatarPath ?? this.avatarPath,
      isVerified: isVerified ?? this.isVerified,
    );
  }

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }
}
