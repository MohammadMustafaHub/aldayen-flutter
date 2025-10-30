import 'package:aldayen/providers/app_client.dart';
import 'package:aldayen/services/auth-service.dart';
import 'package:aldayen/services/user-service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

SetupDependencies()  {
  final appClient = CreateAppClient();
  GetIt.I.registerLazySingleton(() => FlutterSecureStorage());
  GetIt.I.registerLazySingleton(() => appClient);
  GetIt.I.registerLazySingleton(() => AuthService());
  GetIt.I.registerLazySingleton(() => UserService());
}






