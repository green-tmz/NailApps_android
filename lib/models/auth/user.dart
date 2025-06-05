class User {
  final int id;
  final String firstName;
  final String lastName;
  final String secondName;
  final String email;
  final String phone;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.secondName,
    required this.email,
    required this.phone,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      secondName: json['second_name'],
      email: json['email'],
      phone: json['phone'],
    );
  }
}