class User {
  final String id;
  final String email;
  final String name;
  final String role; // 'ADMIN' or 'SERVANT'
  final bool isActive;
  final bool isEnabled;
  final bool activationDenied;
  final String? classId;
  final String? whatsappTemplate;
  final String? phone;
  final bool isEmailConfirmed;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.isActive,
    this.isEnabled = true,
    this.activationDenied = false,
    this.classId,
    this.whatsappTemplate,
    this.phone,
    this.isEmailConfirmed = false,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'] ?? '',
      role: json['role'] ?? 'SERVANT',
      isActive: json['isActive'] ?? false,
      isEnabled: json['isEnabled'] ?? true,
      activationDenied: json['activationDenied'] ?? false,
      classId: json['classId'],
      whatsappTemplate: json['whatsappTemplate'],
      phone: json['phone'],
      isEmailConfirmed: json['isEmailConfirmed'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'isActive': isActive,
      'isEnabled': isEnabled,
      'activationDenied': activationDenied,
      'classId': classId,
      'whatsappTemplate': whatsappTemplate,
      'phone': phone,
      'isEmailConfirmed': isEmailConfirmed,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  User copyWith({
    String? name,
    String? whatsappTemplate,
    String? classId,
    bool? isActive,
    bool? isEnabled,
    bool? activationDenied,
    bool? isEmailConfirmed,
    DateTime? updatedAt,
  }) {
    return User(
      id: id,
      email: email,
      name: name ?? this.name,
      role: role,
      isActive: isActive ?? this.isActive,
      isEnabled: isEnabled ?? this.isEnabled,
      activationDenied: activationDenied ?? this.activationDenied,
      classId: classId ?? this.classId,
      whatsappTemplate: whatsappTemplate ?? this.whatsappTemplate,
      phone: phone,
      isEmailConfirmed: isEmailConfirmed ?? this.isEmailConfirmed,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
