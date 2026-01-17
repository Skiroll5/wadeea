class User {
  final String id;
  final String email;
  final String name;
  final String role; // 'ADMIN' or 'SERVANT'
  final bool isActive;
  final String? classId;
  final String? whatsappTemplate;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.isActive,
    this.classId,
    this.whatsappTemplate,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'] ?? '',
      role: json['role'] ?? 'SERVANT',
      isActive: json['isActive'] ?? false,
      classId: json['classId'],
      whatsappTemplate: json['whatsappTemplate'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'isActive': isActive,
      'classId': classId,
      'whatsappTemplate': whatsappTemplate,
    };
  }

  User copyWith({String? name, String? whatsappTemplate}) {
    return User(
      id: id,
      email: email,
      name: name ?? this.name,
      role: role,
      isActive: isActive,
      classId: classId,
      whatsappTemplate: whatsappTemplate ?? this.whatsappTemplate,
    );
  }
}
