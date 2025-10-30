class User {
  final String id;
  final String name;
  final String phoneNumber;
  final bool isPhoneVerified;

  User({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.isPhoneVerified,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      phoneNumber: json['phoneNumber'],
      isPhoneVerified: json['isPhoneVerified'] ?? false,
    );
  }
}