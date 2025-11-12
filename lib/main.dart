import 'dart:async';
import 'package:aldayen/pages/home.dart';
import 'package:aldayen/providers/getit.dart';
import 'package:aldayen/services/user-service.dart';
import 'package:aldayen/state-management/user-state.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'pages/login.dart';
import 'pages/otp.dart';
import 'pages/connection/no_internet_connection_page.dart';

void main() {
  SetupDependencies();
  WidgetsFlutterBinding.ensureInitialized();
  runApp(BlocProvider(create: (_) => UserCubit(), child: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late UserService _userService;
  bool _isConnected = false;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _userService = GetIt.I<UserService>();
    _checkConnectivity();
    _loadUser();
    _subscribeToConnectivity();
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  void _subscribeToConnectivity() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      final bool isConnected =
          results.contains(ConnectivityResult.wifi) ||
          results.contains(ConnectivityResult.mobile);

      if (mounted) {
        setState(() {
          _isConnected = isConnected;
        });

        // Reload user data when connection is restored
        if (isConnected) {
          _loadUser();
        }
      }
    });
  }

  Future<void> _checkConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();

    if (mounted) {
      final bool isConnected =
          connectivityResult.contains(ConnectivityResult.wifi) ||
          connectivityResult.contains(ConnectivityResult.mobile);

      setState(() {
        _isConnected = isConnected;
      });
    }
  }

  Future<void> _loadUser() async {
    try {
      final userOption = await _userService.getUser();

      if (!mounted) return;

      userOption.match(
        () {
          context.read<UserCubit>().setUser(null);
        },
        (user) {
          context.read<UserCubit>().setUser(user);
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          context.read<UserCubit>().setUser(null);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'الديّن',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF003366),
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Arial',
      ),
      home: !_isConnected
          ? NoInternetConnectionPage(
              onRetry: () {
                _checkConnectivity();
                _loadUser();
              },
            )
          : BlocBuilder<UserCubit, UserState>(
              builder: (context, state) {
                if (state.isLoading) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }

                if (!state.isAuthenticated) {
                  return const LoginPage();
                }

                if (!state.isPhoneVerified) {
                  return const OtpPage();
                }

                return const HomePage();
              },
            ),
    );
  }
}
