import 'package:aldayen/http/api_error_response.dart';
import 'package:aldayen/http/token_response.dart';
import 'package:aldayen/models/user.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fpdart/fpdart.dart';
import 'package:get_it/get_it.dart';

class AuthService {
  late FlutterSecureStorage _storage;
  late Dio _dio;
  AuthService() {
    _storage = GetIt.I<FlutterSecureStorage>();
    _dio = GetIt.I<Dio>();
  }

  Future<Either<ApiErrorResponse, User>> login(
    String phoneNumber,
    String password,
  ) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/login',
        data: {'phoneNumber': phoneNumber, 'password': password},
      );

      if (response.data == null) {
        throw Exception('Response data is null');
      }

      final tokenResponse = TokenResponse.fromJson(
        response.data!['tokenResponse'] as Map<String, dynamic>,
      );

      await _storeTokens(tokenResponse.accessToken, tokenResponse.refreshToken);

      return Right(
        User.fromJson(response.data!['user'] as Map<String, dynamic>),
      );
    } on DioException catch (e) {

      if (e.response?.data != null && e.response?.data["errors"] != null) {
        var errorResponse = ApiErrorResponse.fromJson(
          e.response!.data["errors"] as Map<String, dynamic>,
        );
        return left(errorResponse);
      }

      // Return generic error if no specific error format
      return left(
        ApiErrorResponse(
          errors: [
            {
              "general": ["حدث خطأ أثناء الاتصال بالخادم"],
            },
          ],
        ),
      );
    } catch (e) {
      return left(
        ApiErrorResponse(
          errors: [
            {
              "general": ["حدث خطأ غير متوقع"],
            },
          ],
        ),
      );
    }
  }

  Future<Either<ApiErrorResponse, User>> register(
    String phoneNumber,
    String password,
    String name,
  ) async {
    var res = await _dio.post<Map<String, dynamic>>(
      '/auth/register',
      data: {'phoneNumber': phoneNumber, 'password': password, 'name': name},
    );

    if (res.statusCode != 200) {
      var errorResponse = ApiErrorResponse.fromJson(
        res.data!['errors'] as Map<String, dynamic>,
      );
      return left(errorResponse);
    }
    final tokenResponse = TokenResponse.fromJson(
      res.data!['tokenResponse'] as Map<String, dynamic>,
    );
    await _storeTokens(tokenResponse.accessToken, tokenResponse.refreshToken);

    final user = User.fromJson(res.data!["user"] as Map<String, dynamic>);
    return right(user);
  }

  Future<void> logout() async {
    await _dio.post('/auth/logout');
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
  }

  Future<void> _storeTokens(String accessToken, String refreshToken) async {
    await _storage.write(key: 'access_token', value: accessToken);
    await _storage.write(key: 'refresh_token', value: refreshToken);
  }

  Future<Either<ApiErrorResponse, User>> verifyOtp(String otp) async {
    var res = await _dio.post(
      '/auth/verify-phone',
      data: {'code': otp},
    );

    if (res.statusCode != 200) {
      var errorResponse = ApiErrorResponse.fromJson(
        res.data!['errors'] as Map<String, dynamic>,
      );
      return left(errorResponse);
    }

    final tokenResponse = TokenResponse.fromJson(
      res.data!['tokenResponse'] as Map<String, dynamic>,
    );
    await _storeTokens(tokenResponse.accessToken, tokenResponse.refreshToken);
    return right(User.fromJson(res.data!['user'] as Map<String, dynamic>));
  }

  Future<Either<ApiErrorResponse, bool>> resendOtp() async {
    var res = await _dio.post<Map<String, dynamic>>(
      '/auth/resend-verification-code',
    );

    if (res.statusCode != 200) {
      var errorResponse = ApiErrorResponse.fromJson(
        res.data!['errors'] as Map<String, dynamic>,
      );
      return left(errorResponse);
    }

    return right(true);
  }
}

