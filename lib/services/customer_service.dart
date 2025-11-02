import 'package:aldayen/http/api-error-response.dart';
import 'package:aldayen/models/customer.dart';
import 'package:aldayen/models/paginated_response.dart';
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:get_it/get_it.dart';

enum OrderBy { dueDateAsc, amountAsc, dueDateDesc, amountDesc, none }

class CustomerService {
  late Dio _dio;

  CustomerService() {
    _dio = GetIt.I<Dio>();
  }

  Future<Either<ApiErrorResponse, PaginatedResponse<Customer>>> fetchCustomers(
    int page,
    int pageSize,
    String? search,
    OrderBy? orderBy,
  ) async {
    final response = await _dio.get(
      'api/customers',
      queryParameters: {
        'page': page,
        'pageSize': pageSize,
        'search': search,
        'orderBy': orderBy?.name ?? OrderBy.none.name,
      },
    );

    if (response.statusCode == 200) {
      final data = response.data['data'] as List;
      final customers = data.map((e) => Customer.fromJson(e)).toList();
      final totalItems = response.data['totalItems'] as int;
      final hasNext = response.data['hasNextPage'] as bool;
      final hasPrevious = response.data['hasPreviousPage'] as bool;
      return Right(
        PaginatedResponse(
          data: customers,
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

  Future<Either<ApiErrorResponse, CustomerWithTransactions>> fetchCustomerById(
    String id,
  ) async {
    final response = await _dio.get('api/customers/$id');

    if (response.statusCode == 200) {
      final customer = CustomerWithTransactions.fromJson(response.data);
      return Right(customer);
    } else {
      return Left(ApiErrorResponse.fromJson(response.data));
    }
  }

  Future<Either<ApiErrorResponse, Customer>> createCustomer(
    String name,
    String? phone,
    double debt,
    String? note,
    DateTime? dueDate,
  ) async {
    final response = await _dio.post(
      'api/customers',
      data: {
        'name': name,
        'phone': phone,
        'amount': debt,
        'note': note,
        'paymentDue': dueDate?.toIso8601String(),
      },
    );

    if (response.statusCode == 200) {
      final createdCustomer = Customer.fromJson(response.data);
      return Right(createdCustomer);
    } else {
      return Left(ApiErrorResponse.fromJson(response.data));
    }
  }

  Future<Either<ApiErrorResponse, Customer>> updateCustomer(
    String id,
    String name,
    String phone,
    DateTime? paymentDue,
    String? note,
  ) async {
    final response = await _dio.put(
      'api/customers/$id',
      data: {
        'name': name,
        'phoneNumber': phone,
        'paymentDue': paymentDue?.toIso8601String(),
        'note': note,
      },
    );

    if (response.statusCode == 200) {
      return Right(Customer.fromJson(response.data));
    } else {
      return Left(ApiErrorResponse.fromJson(response.data));
    }
  }

  Future<Either<ApiErrorResponse, List<Customer>>> getSoonPayment() async {
    final response = await _dio.get('api/customers/get-soon-payment');

    if (response.statusCode == 200) {
      final data = response.data as List;
      final customers = data.map((e) => Customer.fromJson(e)).toList();
      return Right(customers);
    } else {
      return Left(ApiErrorResponse.fromJson(response.data));
    }
  }
}
