import 'dart:async';
import 'package:aldayen/pages/Home.dart';
import 'package:aldayen/pages/login.dart';
import 'package:aldayen/services/auth_service.dart';
import 'package:aldayen/state-management/user-state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:get_it/get_it.dart';

class OtpPage extends StatefulWidget {
  const OtpPage({Key? key}) : super(key: key);

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  bool _isLoading = false;
  bool _canResend = true;
  int _resendTimer = 0;
  String phoneNumber = '';
  Timer? _timer;
  late AuthService _authService;
  String? _errorMessage;
  String _otpCode = '';

  @override
  void initState() {
    super.initState();
    _authService = GetIt.I<AuthService>();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    setState(() {
      _canResend = false;
      _resendTimer = 60;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendTimer > 0) {
        setState(() {
          _resendTimer--;
        });
      } else {
        timer.cancel();
        setState(() {
          _canResend = true;
        });
      }
    });
  }

  Future<void> _handleResendCode() async {
    if (!_canResend) return;

    // Clear OTP code
    setState(() {
      _otpCode = '';
    });

    await _authService.resendOtp();

    // Simulate sending new OTP
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم إرسال رمز التحقق إلى $phoneNumber'),
          backgroundColor: Colors.green,
        ),
      );
    }

    // Start timer only after first resend
    _startResendTimer();
  }

  Future<void> _handleVerifyOtp() async {
    if (_otpCode.length < 6 && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء إدخال رمز التحقق كاملاً'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final result = await _authService.verifyOtp(_otpCode);

    result.match(
      (error) {
        setState(() {
          _errorMessage = 'فشل التحقق. الرجاء المحاولة مرة أخرى.';
          _isLoading = false;
        });
      },
      (user) {
        if (mounted) {
          context.read<UserCubit>().setUser(user);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        }
      },
    );

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: Color(0xFF003366)),
              tooltip: 'تسجيل الخروج',
              onPressed: () async {
                await _authService.logout();
                if (mounted) {
                  context.read<UserCubit>().setUser(null);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                }
              },
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),

                // Icon
                Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFF003366).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.message_outlined,
                    size: 50,
                    color: Color(0xFF003366),
                  ),
                ),
                const SizedBox(height: 32),

                // Title
                const Text(
                  'تحقق من رقم الهاتف',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF003366),
                  ),
                ),
                const SizedBox(height: 16),

                // Message
                Text(
                  'تم إرسال رمز التحقق إلى',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                BlocBuilder<UserCubit, UserState>(
                  builder: (context, state) {
                    final phone = state.user?.phoneNumber ?? 'رقم غير متوفر';
                    return Text(
                      phone,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF003366),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 48),

                // OTP Input Fields
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Calculate responsive field width
                      final screenWidth = MediaQuery.of(context).size.width;
                      final availableWidth =
                          screenWidth - 48; // Subtract horizontal padding
                      final fieldWidth =
                          (availableWidth / 6) -
                          12; // Divide by 6 fields and subtract margins
                      final responsiveFieldWidth = fieldWidth.clamp(
                        40.0,
                        48.0,
                      ); // Min 40, Max 48
                      final responsiveFontSize = responsiveFieldWidth < 45
                          ? 18.0
                          : 22.0;

                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: OtpTextField(
                          numberOfFields: 6,
                          borderColor: const Color(0xFF003366),
                          focusedBorderColor: const Color(0xFF003366),
                          enabledBorderColor: Colors.grey[300]!,
                          borderWidth: 2.0,
                          borderRadius: BorderRadius.circular(12),
                          fieldWidth: responsiveFieldWidth,
                          fieldHeight: responsiveFieldWidth < 45 ? 54 : 60,
                          filled: true,
                          fillColor: Colors.grey[50] ?? Colors.grey.shade50,
                          showFieldAsBox: true,
                          textStyle: TextStyle(
                            fontSize: responsiveFontSize,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF003366),
                          ),
                          keyboardType: TextInputType.number,
                          onCodeChanged: (String code) {
                            setState(() {
                              _otpCode = code;
                            });
                          },
                          onSubmit: (String verificationCode) {
                            setState(() {
                              _otpCode = verificationCode;
                            });
                            _handleVerifyOtp();
                          },
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 48),

                // Verify Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleVerifyOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF003366),
                      disabledBackgroundColor: const Color(0xFF003366),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            'تحقق',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                Container(
                  height: 24,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.only(top: 8),
                  child: _errorMessage != null
                      ? Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                const SizedBox(height: 24),

                // Resend Code Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'لم تستلم الرمز؟',
                      style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                    ),
                    const SizedBox(width: 8),
                    if (_canResend)
                      TextButton(
                        onPressed: _handleResendCode,
                        child: const Text(
                          'إعادة الإرسال',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF003366),
                          ),
                        ),
                      )
                    else
                      Row(
                        children: [
                          Icon(
                            Icons.timer_outlined,
                            size: 18,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${_resendTimer.toString().padLeft(2, '0')}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF003366),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'ثانية',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 32),

                // Info Message
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.blue.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Colors.blue,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'تحقق من رسائلك النصية للحصول على رمز التحقق المكون من 6 أرقام',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
