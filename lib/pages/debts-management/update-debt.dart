import 'package:aldayen/models/transaction.dart';
import 'package:aldayen/models/customer.dart';
import 'package:aldayen/components/transaction_card.dart';
import 'package:aldayen/services/customer_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class UpdateDebtPage extends StatefulWidget {
  final String debtId;

  const UpdateDebtPage({Key? key, required this.debtId}) : super(key: key);

  @override
  State<UpdateDebtPage> createState() => _UpdateDebtPageState();
}

class _UpdateDebtPageState extends State<UpdateDebtPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _transactionAmountController = TextEditingController();
  final _notesController = TextEditingController();

  late TabController _tabController;
  final CustomerService _customerService = GetIt.I<CustomerService>();

  CustomerWithTransactions? _customerData;
  List<Transaction> _transactions = [];
  double _remaining = 0;
  bool _isLoading = false;
  bool _isLoadingData = true;
  String _transactionType = 'deposit'; // 'deposit' or 'add_debt'
  String? _errorMessage;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadDebtData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _transactionAmountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // Load customer data from API
  Future<void> _loadDebtData() async {
    setState(() {
      _isLoadingData = true;
      _errorMessage = null;
    });

    final result = await _customerService.fetchCustomerById(widget.debtId);

    result.fold(
      (error) {
        setState(() {
          _errorMessage = 'حدث خطأ أثناء تحميل البيانات';
          _isLoadingData = false;
        });
      },
      (customerData) {
        setState(() {
          _customerData = customerData;
          _nameController.text = customerData.customer.name;
          _phoneController.text = customerData.customer.phoneNumber ?? '';
          _notesController.text = customerData.customer.note ?? '';
          _selectedDate = customerData.customer.paymentDue;
          _transactions = customerData.transactions;
          _remaining = customerData.customer.totalDebt;
          _isLoadingData = false;
        });
      },
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
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

  Future<void> _handleUpdateInfo() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final result = await _customerService.updateCustomer(
        widget.debtId,
        _nameController.text,
        _phoneController.text,
        _selectedDate,
        _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      setState(() {
        _isLoading = false;
      });

      result.fold(
        (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('حدث خطأ أثناء تحديث البيانات'),
              backgroundColor: Colors.red,
            ),
          );
        },
        (updatedCustomer) {
          // Update local customer data
          if (_customerData != null) {
            _customerData = CustomerWithTransactions(
              customer: updatedCustomer,
              transactions: _customerData!.transactions,
            );
          }

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم تحديث معلومات المدين بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
        },
      );
    }
  }

  void _showAddTransactionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header with Icon
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF003366).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.add_circle_outline,
                              color: Color(0xFF003366),
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Text(
                              'إضافة معاملة جديدة',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF003366),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Transaction Type Label
                      Text(
                        'نوع المعاملة',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Transaction Type Selector (Custom Cards)
                      Row(
                        children: [
                          // Deposit Card
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                setDialogState(() {
                                  _transactionType = 'deposit';
                                });
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: _transactionType == 'deposit'
                                      ? Colors.green.withOpacity(0.1)
                                      : Colors.grey[100],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _transactionType == 'deposit'
                                        ? Colors.green
                                        : Colors.grey[300]!,
                                    width: 2,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.arrow_downward,
                                      color: _transactionType == 'deposit'
                                          ? Colors.green
                                          : Colors.grey[600],
                                      size: 32,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'إيداع',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: _transactionType == 'deposit'
                                            ? Colors.green
                                            : Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Add Debt Card
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                setDialogState(() {
                                  _transactionType = 'add_debt';
                                });
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: _transactionType == 'add_debt'
                                      ? Colors.red.withOpacity(0.1)
                                      : Colors.grey[100],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _transactionType == 'add_debt'
                                        ? Colors.red
                                        : Colors.grey[300]!,
                                    width: 2,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.arrow_upward,
                                      color: _transactionType == 'add_debt'
                                          ? Colors.red
                                          : Colors.grey[600],
                                      size: 32,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'دين جديد',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: _transactionType == 'add_debt'
                                            ? Colors.red
                                            : Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Amount Label
                      Text(
                        'المبلغ',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Amount Field
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey[300]!,
                            width: 1,
                          ),
                        ),
                        child: TextFormField(
                          controller: _transactionAmountController,
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
                            suffixIcon: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                'د.ع',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(20),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 50,
                              child: OutlinedButton(
                                onPressed: () {
                                  _transactionAmountController.clear();
                                  Navigator.pop(context);
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.grey[700],
                                  side: BorderSide(color: Colors.grey[300]!),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'إلغاء',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: SizedBox(
                              height: 50,
                              child: ElevatedButton(
                                onPressed: () {
                                  if (_transactionAmountController
                                      .text
                                      .isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('الرجاء إدخال المبلغ'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }

                                  final amount = double.tryParse(
                                    _transactionAmountController.text,
                                  );
                                  if (amount == null || amount <= 0) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('الرجاء إدخال مبلغ صحيح'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }

                                  Navigator.pop(context);

                                  // Simulate adding transaction
                                  setState(() {
                                    if (_transactionType == 'deposit') {
                                      _remaining -= amount;
                                    } else {
                                      _remaining += amount;
                                    }

                                    // Add to transactions list
                                    _transactions.insert(
                                      0,
                                      Transaction(
                                        id: DateTime.now()
                                            .millisecondsSinceEpoch
                                            .toString(),
                                        type: _transactionType == 'deposit'
                                            ? TransactionType.payment
                                            : TransactionType.debit,
                                        amount: amount,
                                        createdAt: DateTime.now(),
                                      ),
                                    );
                                  });

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        _transactionType == 'deposit'
                                            ? 'تم إضافة الإيداع بنجاح'
                                            : 'تم إضافة الدين بنجاح',
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  );

                                  _transactionAmountController.clear();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _transactionType == 'deposit'
                                      ? Colors.green
                                      : Colors.red,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.check_circle),
                                    const SizedBox(width: 8),
                                    Text(
                                      _transactionType == 'deposit'
                                          ? 'إضافة إيداع'
                                          : 'إضافة دين',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _handleDeleteDebt() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text('تأكيد الحذف'),
            content: const Text(
              'هل أنت متأكد من حذف هذا المدين وجميع معاملاته؟',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  // Simulate delete API call
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم حذف المدين بنجاح'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pop(context); // Close update page
                },
                child: const Text('حذف', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          backgroundColor: const Color(0xFF003366),
          elevation: 0,
          title: const Text(
            'إدارة المدين',
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
          actions: [
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.white),
              onPressed: _handleDeleteDebt,
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            tabs: const [
              Tab(text: 'معلومات المدين'),
              Tab(text: 'المعاملات السابقة'),
            ],
          ),
        ),
        body: _isLoadingData
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF003366)),
              )
            : _errorMessage != null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _loadDebtData,
                      icon: const Icon(Icons.refresh),
                      label: const Text('إعادة المحاولة'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF003366),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : TabBarView(
                controller: _tabController,
                children: [_buildDebtorInfoTab(), _buildTransactionsTab()],
              ),
      ),
    );
  }

  Widget _buildDebtorInfoTab() {
    return SafeArea(
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
                    Icons.person,
                    size: 40,
                    color: Color(0xFF003366),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'ID: ${widget.debtId}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ),
              const SizedBox(height: 24),

              // Debt Summary Card
              _buildSummaryCard(
                'المتبقي',
                _remaining,
                const Color(0xFF003366),
                isLarge: true,
              ),
              const SizedBox(height: 24),

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
                  fillColor: Colors.white,
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
                  prefixIcon: const Icon(Icons.phone, color: Color(0xFF003366)),
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
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty && value.length < 10) {
                    return 'رقم الهاتف يجب أن يكون 10 أرقام على الأقل';
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
                    color: Colors.white,
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
                      if (_selectedDate != null)
                        IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () {
                            setState(() {
                              _selectedDate = null;
                            });
                          },
                          color: Colors.grey[600],
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
                    child: Icon(Icons.note_outlined, color: Color(0xFF003366)),
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
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 32),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _handleUpdateInfo,
                        icon: const Icon(Icons.save),
                        label: const Text('حفظ التعديلات'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF003366),
                          disabledBackgroundColor: const Color(0xFF003366),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Add Transaction Button
              SizedBox(
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: _showAddTransactionDialog,
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('إضافة معاملة'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF003366),
                    side: const BorderSide(color: Color(0xFF003366), width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionsTab() {
    return SafeArea(
      child: _transactions.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'لا توجد معاملات',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: _transactions.length,
              itemBuilder: (context, index) {
                final transaction = _transactions[index];
                return TransactionCard(transaction: transaction);
              },
            ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    double amount,
    Color color, {
    bool isLarge = false,
  }) {
    return Container(
      padding: EdgeInsets.all(isLarge ? 20 : 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: isLarge ? 16 : 14,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${amount.toStringAsFixed(2)} د.ع',
            style: TextStyle(
              fontSize: isLarge ? 24 : 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
