import 'dart:async';
import 'package:aldayen/pages/password/forgot_password_change.dart';
import 'package:aldayen/services/password_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';

class ChangePasswordOtpPage extends StatefulWidget {
  final String phoneNumber;

  const ChangePasswordOtpPage({Key? key, required this.phoneNumber})
    : super(key: key);

  @override
  State<ChangePasswordOtpPage> createState() => _ChangePasswordOtpPageState();
}

class _ChangePasswordOtpPageState extends State<ChangePasswordOtpPage> {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  bool _isLoading = false;
  bool _canResend = true;
  int _resendTimer = 0;
  Timer? _timer;
  String? _errorMessage;
  late PasswordService _passwordService;

  @override
  void initState() {
    super.initState();
    _passwordService = GetIt.I<PasswordService>();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
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

  Future<void> _handleVerifyOtp() async {
    // Get OTP code
    String otpCode = _otpControllers.map((c) => c.text).join();

    if (otpCode.length < 6 && mounted) {
      setState(() {
        _errorMessage = 'الرجاء إدخال رمز التحقق كاملاً';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final token = await _passwordService.RequestChangePasswordToken(otpCode);

      if (!mounted) return;

      if (token != null && token.isNotEmpty) {
        // Token received successfully
        setState(() {
          _isLoading = false;
        });

        // Navigate to password change page with token
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ForgotPasswordChangePage(
              token: token,
              phoneNumber: widget.phoneNumber,
            ),
          ),
        );
      } else {
        // Failed to verify OTP
        setState(() {
          _isLoading = false;
          _errorMessage = 'رمز التحقق غير صحيح. الرجاء المحاولة مرة أخرى.';
        });
      }
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage =
            'حدث خطأ أثناء التحقق من الرمز. الرجاء المحاولة مرة أخرى.';
      });
    }
  }

  Future<void> _handleResendOtp() async {
    if (!_canResend) return;

    // Clear all OTP fields
    for (var controller in _otpControllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();

    setState(() {
      _errorMessage = null;
    });

    try {
      final result = await _passwordService.requestChangePasswordOtp(
        widget.phoneNumber,
      );

      if (!mounted) return;

      if (result) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم إرسال رمز التحقق إلى ${widget.phoneNumber}'),
            backgroundColor: Colors.green,
          ),
        );
        _startResendTimer();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('فشل إعادة إرسال رمز التحقق'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('حدث خطأ أثناء إعادة إرسال الرمز'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            'التحقق من رمز OTP',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          backgroundColor: const Color(0xFF003366),
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),

                // Icon
                Container(
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFF003366).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.message_outlined,
                    size: 40,
                    color: Color(0xFF003366),
                  ),
                ),
                const SizedBox(height: 24),

                // Title
                const Text(
                  'تحقق من رمز OTP',
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
                Text(
                  widget.phoneNumber,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF003366),
                  ),
                ),
                const SizedBox(height: 48),

                // OTP Input Fields
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(6, (index) {
                      return Flexible(
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 50),
                          height: 60,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          child: TextFormField(
                            controller: _otpControllers[index],
                            focusNode: _focusNodes[index],
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            maxLength: 1,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF003366),
                            ),
                            decoration: InputDecoration(
                              counterText: '',
                              filled: true,
                              fillColor: Colors.grey[50],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFF003366),
                                  width: 2,
                                ),
                              ),
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            onChanged: (value) {
                              if (value.isNotEmpty) {
                                // Move to next field
                                if (index < 5) {
                                  _focusNodes[index + 1].requestFocus();
                                } else {
                                  // Last field, remove focus
                                  _focusNodes[index].unfocus();
                                }
                              } else {
                                // Move to previous field on delete
                                if (index > 0) {
                                  _focusNodes[index - 1].requestFocus();
                                }
                              }
                            },
                          ),
                        ),
                      );
                    }),
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
                        onPressed: _handleResendOtp,
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
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.blue.withOpacity(0.3),
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
