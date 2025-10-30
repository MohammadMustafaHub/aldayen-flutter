import 'package:aldayen/models/user.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fpdart/fpdart.dart';
import 'package:get_it/get_it.dart';

class UserService {
  late final Dio _client;
  late final FlutterSecureStorage _storage;
  UserService() {
    _client = GetIt.I<Dio>();
    _storage = GetIt.I<FlutterSecureStorage>();
  }

  Future<Option<User>> getUser() async {
    String? token = await _storage.read(key: 'access_token');
    if (token == null) return none();

    try {
      final response = await _client.get(
        'auth/user',
      );


      if (response.statusCode == 200) {
        return some(User.fromJson(response.data));
      } else {
        return none();
      }
    } catch (e) {
      print('Exception fetching user: $e');
      return none();
    }
  }
}
