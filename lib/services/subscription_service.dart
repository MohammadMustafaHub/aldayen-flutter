import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

class SubscriptionService {
  late Dio _dio;
  SubscriptionService() {
    _dio = GetIt.I<Dio>();
  }

  Future<bool> requestSubscription() async {
    final response = await _dio.post('api/Subscription/request/subscription');
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }
}
