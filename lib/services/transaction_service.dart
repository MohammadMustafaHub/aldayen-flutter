import 'package:aldayen/http/api_error_response.dart';
import 'package:aldayen/models/customer.dart';
import 'package:aldayen/models/paginated_response.dart';
import 'package:aldayen/models/transaction.dart';
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:get_it/get_it.dart';

class TransactionService {
  late Dio _dio;

  TransactionService() {
    _dio = GetIt.I<Dio>();
  }

  Future<Either<ApiErrorResponse, CustomerWithTransactions>> AddDebt(String customerId, double amount) async {
    final res = await _dio.post('api/debt/add-debt/$customerId', data: {
      'amount': amount,
    });

    if (res.statusCode == 200) {
      return Right(CustomerWithTransactions.fromJson(res.data));
    } else {
      return Left(ApiErrorResponse.fromJson(res.data));
    }
  }

  Future<Either<ApiErrorResponse, CustomerWithTransactions>> PayDebt(String customerId, double amount) async {
    final res = await _dio.post('api/debt/add-payment/$customerId', data: {
      'amount': amount,
    });

    if (res.statusCode == 200) {
      return Right(CustomerWithTransactions.fromJson(res.data));
    } else {
      return Left(ApiErrorResponse.fromJson(res.data));
    }
  }

  Future<Either<ApiErrorResponse, PaginatedResponse<Transaction>>> getTransactions(int page, int pageSize) async {
    final response = await _dio.get(
      'api/transactions',
      queryParameters: {
        'page': page,
        'pageSize': pageSize,
      },
    );

    if (response.statusCode == 200) {
      final data = response.data['data'] as List;
      final transactions = data.map((e) => Transaction.fromJson(e)).toList();
      final totalItems = response.data['totalItems'] as int;
      final hasNext = response.data['hasNextPage'] as bool;
      final hasPrevious = response.data['hasPreviousPage'] as bool;
      return Right(
        PaginatedResponse(
          data: transactions,
          page: page,
          pageSize: pageSize,
          totalItems: totalItems,
          hasNext: hasNext,
          hasPrevious: hasPrevious,
        ),
      );
    } else {
      return Left(ApiErrorResponse.fromJson(response.data));
    }
  }
}
