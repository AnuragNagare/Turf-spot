enum PreferredSport {
  cricket,
  football,
  both;

  String get displayName {
    switch (this) {
      case PreferredSport.cricket:
        return 'Cricket';
      case PreferredSport.football:
        return 'Football';
      case PreferredSport.both:
        return 'Both';
    }
  }

  static PreferredSport fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'cricket':
        return PreferredSport.cricket;
      case 'football':
        return PreferredSport.football;
      default:
        return PreferredSport.both;
    }
  }
}

class UserModel {
  final String id;
  final String name;
  final String? email;
  final String? phone;
  final String? photoUrl;
  final PreferredSport preferredSport;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.photoUrl,
    this.preferredSport = PreferredSport.both,
    required this.createdAt,
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? photoUrl,
    PreferredSport? preferredSport,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      preferredSport: preferredSport ?? this.preferredSport,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'photoUrl': photoUrl,
      'preferredSport': preferredSport.name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'],
      phone: map['phone'],
      photoUrl: map['photoUrl'],
      preferredSport: PreferredSport.fromString(map['preferredSport']),
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
