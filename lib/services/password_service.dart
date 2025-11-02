import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

class PasswordService {
  late Dio _dio;

  PasswordService() {
    _dio = GetIt.I<Dio>();
  }

  Future<bool> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    final response = await _dio.post(
      'api/password/change-password',
      data: {'oldPassword': currentPassword, 'newPassword': newPassword},
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> requestChangePasswordOtp(String phoneNumber) async {
    final response = await _dio.post(
      'api/password/send-verification-code',
      data: {'phoneNumber': phoneNumber},
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<String?> RequestChangePasswordToken(String otpCode) async {
    final response = await _dio.get(
      'api/password/verify-phone',
      queryParameters: {'code': otpCode},
    );

    if (response.statusCode == 200) {
      return response.data['token'];
    } else {
      return null;
    }
  }

  Future<bool> resetPassword(
    String token,
    String phoneNumber,
    String newPassword,
  ) async {
    final response = await _dio.post(
      'api/password/change-password-with-token',
      data: {
        'token': token,
        'phoneNumber': phoneNumber,
        'newPassword': newPassword,
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }
}
