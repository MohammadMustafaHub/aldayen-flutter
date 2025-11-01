import 'package:aldayen/services/customer_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class CreateDebtPage extends StatefulWidget {
  const CreateDebtPage({Key? key}) : super(key: key);

  @override
  State<CreateDebtPage> createState() => _CreateDebtPageState();
}

class _CreateDebtPageState extends State<CreateDebtPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime? _selectedDate;
  bool _isLoading = false;
  late final CustomerService _customerService;

  @override
  void initState() {
    super.initState();
    _customerService = GetIt.I<CustomerService>();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF003366),
              onPrimary: Colors.white,
              onSurface: Color(0xFF003366),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _handleCreateDebt() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      _createDebt();
    }
  }

  Future<void> _createDebt() async {
    try {
      final amount = double.parse(_amountController.text);

      final result = await _customerService.createCustomer(
        _nameController.text,
        _phoneController.text.isNotEmpty ? _phoneController.text : null,
        amount,
        _notesController.text.isNotEmpty ? _notesController.text : null,
        _selectedDate,
      );

      result.match(
        (error) {
          setState(() {
            _isLoading = false;
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('فشل في إضافة الدين'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        (customer) {
          setState(() {
            _isLoading = false;
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم إضافة الدين بنجاح'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          }
        },
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('حدث خطأ غير متوقع'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
            'إضافة دين جديد',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_forward, color: Colors.white),
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
                  // Icon
                  Center(
                    child: Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFF003366).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add_card,
                        size: 40,
                        color: Color(0xFF003366),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Name Field
                  TextFormField(
                    controller: _nameController,
                    keyboardType: TextInputType.name,
                    style: const TextStyle(fontSize: 16),
                    decoration: InputDecoration(
                      labelText: 'اسم المدين',
                      hintText: 'أدخل اسم المدين',
                      prefixIcon: const Icon(
                        Icons.person_outline,
                        color: Color(0xFF003366),
                      ),
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
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'الرجاء إدخال اسم المدين';
                      }
                      if (value.length < 3) {
                        return 'الاسم يجب أن يكون 3 أحرف على الأقل';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Phone Field
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(fontSize: 16),
                    decoration: InputDecoration(
                      labelText: 'رقم الهاتف (اختياري)',
                      hintText: '05xxxxxxxx',
                      prefixIcon: const Icon(
                        Icons.phone,
                        color: Color(0xFF003366),
                      ),
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
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    validator: (value) {
                      if (value != null &&
                          value.isNotEmpty &&
                          value.length < 10) {
                        return 'رقم الهاتف يجب أن يكون 10 أرقام على الأقل';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Amount Field
                  TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    style: const TextStyle(fontSize: 16),
                    decoration: InputDecoration(
                      labelText: 'المبلغ',
                      hintText: '0.00',
                      prefixIcon: const Icon(
                        Icons.attach_money,
                        color: Color(0xFF003366),
                      ),
                      suffixText: 'د.ع',
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
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'الرجاء إدخال المبلغ';
                      }
                      final amount = double.tryParse(value);
                      if (amount == null || amount <= 0) {
                        return 'الرجاء إدخال مبلغ صحيح';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Due Date Field
                  InkWell(
                    onTap: () => _selectDate(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 18,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            color: Color(0xFF003366),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              _selectedDate == null
                                  ? 'تاريخ الاستحقاق (اختياري)'
                                  : '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}',
                              style: TextStyle(
                                fontSize: 16,
                                color: _selectedDate == null
                                    ? Colors.grey[600]
                                    : Colors.black,
                              ),
                            ),
                          ),
                          Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Notes Field
                  TextFormField(
                    controller: _notesController,
                    keyboardType: TextInputType.multiline,
                    maxLines: 4,
                    style: const TextStyle(fontSize: 16),
                    decoration: InputDecoration(
                      labelText: 'ملاحظات (اختياري)',
                      hintText: 'أضف أي ملاحظات إضافية...',
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(bottom: 60),
                        child: Icon(
                          Icons.note_outlined,
                          color: Color(0xFF003366),
                        ),
                      ),
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
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Create Button
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleCreateDebt,
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
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text(
                              'إضافة الدين',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
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
