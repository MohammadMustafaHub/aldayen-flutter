import 'package:aldayen/pages/home.dart';
import 'package:aldayen/providers/getit.dart';
import 'package:aldayen/services/user-service.dart';
import 'package:aldayen/state-management/user-state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'pages/login.dart';
import 'pages/otp.dart';

void main() {
  SetupDependencies();

runApp(
    BlocProvider(
      create: (_) => UserCubit(),
      child: MyApp(),
    ),
  );}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late UserService _userService;

  // 1. Add a loading state

  @override
  void initState() {
    super.initState();
    _userService = GetIt.I<UserService>();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final userOption = await _userService.getUser();

      if (!mounted) return;

      setState(() {
        userOption.match(
          () {
            context.read<UserCubit>().setUser(null);

          },
          (user) {
            context.read<UserCubit>().setUser(user);
          },
        );
        // 2. Turn off loading, no matter what
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          // 2. Turn off loading even if there's an error
          context.read<UserCubit>().setUser(null);
        });
      }
    }
  }

  // 3. This is a helper widget to show a loading screen

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
      home: BlocBuilder<UserCubit, UserState>(
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
