import 'package:aldayen/models/tenant_info.dart';

class User {
  final String id;
  final String name;
  final String phoneNumber;
  final bool isPhoneVerified;
  final TenantInfo tenantInfo;

  User({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.tenantInfo,
    required this.isPhoneVerified,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      phoneNumber: json['phoneNumber'],
      isPhoneVerified: json['isPhoneVerified'] ?? false,
      tenantInfo: TenantInfo.fromJson(json['tenantInfo']),
    );
  }
}

