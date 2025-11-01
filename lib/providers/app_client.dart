import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// final _appUrl = 'https://aldayen.sliplane.app/';
final _appUrl = 'http://localhost:5121/';

Dio CreateAppClient() {
  final client = Dio(
    BaseOptions(
      baseUrl: _appUrl, // Replace with your API base URL
      connectTimeout: Duration(milliseconds: 10000),
      receiveTimeout: Duration(milliseconds: 10000),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      validateStatus: (status) {
        if (status == 401) return false;
        return true;
      },
    ),
  );

  client.interceptors.add(
    LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
      request: true,
      requestHeader: true,
      responseHeader: true,
    ),
  );

  client.interceptors.add(AuthInterceptor(FlutterSecureStorage()));

  return client;
}

class AuthInterceptor extends QueuedInterceptor {
  final FlutterSecureStorage _storage;
  Completer<String?>? _refreshCompleter;

  AuthInterceptor(this._storage);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.read(key: 'access_token');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Prevent infinite loop: don't refresh if this is a refresh request
    if (err.requestOptions.path.contains('/auth/refresh')) {
      return handler.next(err);
    }
    if (err.response?.statusCode == 401) {
      try {
        final newToken = await _refreshTokenThreadSafe();
        if (newToken != null) {
          // Retry the original request with the new token, using a new Dio instance
          final opts = err.requestOptions;
          opts.headers['Authorization'] = 'Bearer $newToken';
          final retryDio = Dio(
            BaseOptions(
              baseUrl: opts.baseUrl,
              headers: opts.headers,
              connectTimeout: opts.connectTimeout,
              receiveTimeout: opts.receiveTimeout,
            ),
          );
          final response = await retryDio.fetch(opts);
          return handler.resolve(response);
        }
      } catch (e) {
        // fall through to next handler
      }
    }
    return handler.next(err);
  }

  Future<String?> _refreshTokenThreadSafe() async {
    if (_refreshCompleter != null) {
      // A refresh is already in progress, wait for it
      return _refreshCompleter!.future;
    }
    _refreshCompleter = Completer<String?>();
    try {
      final newToken = await _refreshToken();
      _refreshCompleter!.complete(newToken);
      return newToken;
    } catch (e) {
      _refreshCompleter!.complete(null);
      return null;
    } finally {
      _refreshCompleter = null;
    }
  }

  Future<String?> _refreshToken() async {
    final refreshToken = await _storage.read(key: 'refresh_token');
    if (refreshToken == null) {
      await _storage.delete(key: 'access_token');
      await _storage.delete(key: 'refresh_token');
      return null;
    }
    try {
      Dio client = Dio(
        BaseOptions(
          baseUrl: _appUrl,
          headers: {'Content-Type': 'application/json'},
        ),
      );
      final res = await client.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );
      if (res.statusCode == 200 && res.data['accessToken'] != null) {
        String newToken = res.data['accessToken'];
        await _storage.write(key: 'access_token', value: newToken);
        return newToken;
      }
    } catch (e) {
      print(e);
    }
    // await _storage.delete(key: 'access_token');
    // await _storage.delete(key: 'refresh_token');
    return null;
  }
}
