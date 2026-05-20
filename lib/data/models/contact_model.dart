class ContactModel {
  final int? id;
  final String name;
  final String phone;
  final bool isFavorite;
  final String? avatarPath;
  final String? upiId;
  final String? bank;

  const ContactModel({
    this.id,
    required this.name,
    required this.phone,
    this.isFavorite = false,
    this.avatarPath,
    this.upiId,
    this.bank,
  });

  factory ContactModel.fromMap(Map<String, dynamic> map) {
    return ContactModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      phone: map['phone'] as String,
      isFavorite: (map['is_favorite'] as int? ?? 0) == 1,
      avatarPath: map['avatar_path'] as String?,
      upiId: map['upi_id'] as String?,
      bank: map['bank'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'phone': phone,
      'is_favorite': isFavorite ? 1 : 0,
      'avatar_path': avatarPath,
      'upi_id': upiId,
      'bank': bank,
    };
  }

  ContactModel copyWith({
    int? id,
    String? name,
    String? phone,
    bool? isFavorite,
    String? avatarPath,
    String? upiId,
    String? bank,
  }) {
    return ContactModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      isFavorite: isFavorite ?? this.isFavorite,
      avatarPath: avatarPath ?? this.avatarPath,
      upiId: upiId ?? this.upiId,
      bank: bank ?? this.bank,
    );
  }

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}
