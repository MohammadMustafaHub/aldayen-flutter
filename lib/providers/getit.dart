import 'package:aldayen/providers/app_client.dart';
import 'package:aldayen/services/auth-service.dart';
import 'package:aldayen/services/customer_service.dart';
import 'package:aldayen/services/password_service.dart';
import 'package:aldayen/services/stats_service.dart';
import 'package:aldayen/services/transaction_service.dart';
import 'package:aldayen/services/user-service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

SetupDependencies() {
  final appClient = CreateAppClient();
  GetIt.I.registerLazySingleton(() => FlutterSecureStorage());
  GetIt.I.registerLazySingleton(() => appClient);
  GetIt.I.registerLazySingleton(() => AuthService());
  GetIt.I.registerLazySingleton(() => UserService());
  GetIt.I.registerLazySingleton(() => CustomerService());
  GetIt.I.registerLazySingleton(() => TransactionService());
  GetIt.I.registerLazySingleton(() => PasswordService());
  GetIt.I.registerLazySingleton(() => StatsService());
}
