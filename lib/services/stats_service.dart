import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

class StatsService {
  late Dio _dio;

  StatsService() {
    _dio = GetIt.I<Dio>();
  }

  Future<GetStatsResponse> getStats() async {
    try {
      final response = await _dio.get('api/stats');
      return GetStatsResponse.fromJson(response.data);
    } catch (e) {
      // Handle error
      rethrow;
    }
  }
}

class GetStatsResponse {
  final double totalDebt;
  final int totalCustomers;
  final int totalDebatedCustomers;
  final double minDebt;
  final double maxDebt;
  final int soonDueDateDebt;
  final int overDueDateDebt;

  GetStatsResponse({
    required this.totalDebt,
    required this.totalCustomers,
    required this.totalDebatedCustomers,
    required this.minDebt,
    required this.maxDebt,
    required this.soonDueDateDebt,
    required this.overDueDateDebt,
  });

  // JSON deserialization
  factory GetStatsResponse.fromJson(Map<String, dynamic> json) {
    return GetStatsResponse(
      totalDebt: (json['totalDebt'] as num).toDouble(),
      totalCustomers: json['totalCustomers'] as int,
      totalDebatedCustomers: json['totalDebatedCustomers'] as int,
      minDebt: (json['minDebt'] as num).toDouble(),
      maxDebt: (json['maxDebt'] as num).toDouble(),
      soonDueDateDebt: json['soonDueDateDebt'] as int,
      overDueDateDebt: json['overDueDateDebt'] as int,
    );
  }

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'totalDebt': totalDebt,
      'totalCustomers': totalCustomers,
      'totalDebatedCustomers': totalDebatedCustomers,
      'minDebt': minDebt,
      'maxDebt': maxDebt,
      'soonDueDateDebt': soonDueDateDebt,
      'overDueDateDebt': overDueDateDebt,
    };
  }
}
