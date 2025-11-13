import 'package:aldayen/models/customer.dart';
import 'package:aldayen/services/transaction_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class CreateTransactionPage extends StatefulWidget {
  final Customer customer;

  const CreateTransactionPage({super.key, required this.customer});

  @override
  State<CreateTransactionPage> createState() => _CreateTransactionPageState();
}

class _CreateTransactionPageState extends State<CreateTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final TransactionService _transactionService = GetIt.I<TransactionService>();

  String _transactionType = 'payment'; // 'payment' or 'debt'
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _handleCreateTransaction() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final amount = double.parse(_amountController.text);
      final note = _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim();

      final result = _transactionType == 'payment'
          ? await _transactionService.PayDebt(widget.customer.id, amount)
          : await _transactionService.AddDebt(widget.customer.id, amount, note);

      setState(() {
        _isLoading = false;
      });

      result.fold(
        (error) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('حدث خطأ أثناء إضافة المعاملة'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        (customerData) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  _transactionType == 'payment'
                      ? 'تم إضافة الدفعة بنجاح'
                      : 'تم إضافة الدين بنجاح',
                ),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context, customerData);
          }
        },
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
          backgroundColor: const Color(0xFF003366),
          elevation: 0,
          title: const Text(
            'إضافة معاملة جديدة',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Customer Info Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF003366).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF003366).withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF003366,
                            ).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.person,
                            color: Color(0xFF003366),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.customer.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF003366),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'الدين الحالي: ${widget.customer.totalDebt.toStringAsFixed(2)} د.ع',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Transaction Type Label
                  Text(
                    'نوع المعاملة',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Transaction Type Selector
                  Row(
                    children: [
                      // Payment Card
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _transactionType = 'payment';
                            });
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: _transactionType == 'payment'
                                  ? Colors.green.withValues(alpha: 0.1)
                                  : Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _transactionType == 'payment'
                                    ? Colors.green
                                    : Colors.grey[300]!,
                                width: 2,
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.arrow_downward,
                                  color: _transactionType == 'payment'
                                      ? Colors.green
                                      : Colors.grey[600],
                                  size: 36,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'دفعة',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: _transactionType == 'payment'
                                        ? Colors.green
                                        : Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'تسديد دين',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _transactionType == 'payment'
                                        ? Colors.green[700]
                                        : Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Add Debt Card
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _transactionType = 'debt';
                            });
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: _transactionType == 'debt'
                                  ? Colors.red.withValues(alpha: 0.1)
                                  : Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _transactionType == 'debt'
                                    ? Colors.red
                                    : Colors.grey[300]!,
                                width: 2,
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.arrow_upward,
                                  color: _transactionType == 'debt'
                                      ? Colors.red
                                      : Colors.grey[600],
                                  size: 36,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'دين جديد',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: _transactionType == 'debt'
                                        ? Colors.red
                                        : Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'إضافة دين',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _transactionType == 'debt'
                                        ? Colors.red[700]
                                        : Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Amount Field
                  Text(
                    'المبلغ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF003366),
                    ),
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: '0.00',
                      hintStyle: TextStyle(
                        fontSize: 24,
                        color: Colors.grey[400],
                      ),
                      suffixText: 'د.ع',
                      suffixStyle: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF003366),
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.all(20),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'الرجاء إدخال المبلغ';
                      }
                      final amount = double.tryParse(value);
                      if (amount == null || amount <= 0) {
                        return 'الرجاء إدخال مبلغ صحيح';
                      }
                      // Validate payment doesn't exceed available debt
                      if (_transactionType == 'payment' &&
                          amount > widget.customer.totalDebt) {
                        return 'المبلغ المدخل أكبر من الدين المتبقي (${widget.customer.totalDebt.toStringAsFixed(2)} د.ع)';
                      }
                      return null;
                    },
                  ),

                  // Note Field (only for debt)
                  if (_transactionType == 'debt') ...[
                    const SizedBox(height: 32),
                    Text(
                      'ملاحظة (اختياري)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _noteController,
                      maxLines: 3,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF003366),
                      ),
                      decoration: InputDecoration(
                        hintText: 'أضف ملاحظة للدين...',
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[400],
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF003366),
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                  ],

                  const SizedBox(height: 40),

                  // Create Button
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleCreateTransaction,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _transactionType == 'payment'
                            ? Colors.green
                            : Colors.red,
                        disabledBackgroundColor: _transactionType == 'payment'
                            ? Colors.green
                            : Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.check_circle, size: 24),
                                const SizedBox(width: 12),
                                Text(
                                  _transactionType == 'payment'
                                      ? 'إضافة دفعة'
                                      : 'إضافة دين',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
