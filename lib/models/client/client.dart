class Client {
  final int id;
  final int? userId;
  final String firstName;
  final String? lastName;
  final String? phone;
  final String? email;
  final String? notes;
  final DateTime? birthDate;

  Client({
    required this.id,
    this.userId,
    required this.firstName,
    this.lastName,
    this.phone,
    this.email,
    this.notes,
    this.birthDate,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'],
      userId: json['user_id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      phone: json['phone'],
      email: json['email'],
      notes: json['notes'],
      birthDate: json['birth_date'] != null
          ? DateTime.tryParse(json['birth_date'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'email': email,
      'notes': notes,
      'birth_date': birthDate?.toIso8601String(),
    };
  }
}