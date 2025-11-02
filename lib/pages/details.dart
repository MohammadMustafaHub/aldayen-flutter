import 'package:aldayen/models/customer.dart';
import 'package:aldayen/models/transaction.dart';
import 'package:aldayen/pages/debts-management/create-debt.dart';
import 'package:aldayen/pages/transactions/transactions_page.dart';
import 'package:aldayen/services/customer_service.dart';
import 'package:aldayen/services/transaction_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class DetailsPage extends StatefulWidget {
  final VoidCallback? onNavigateToDebts;

  const DetailsPage({Key? key, this.onNavigateToDebts}) : super(key: key);

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  late CustomerService _customerService;
  late TransactionService _transactionService;
  bool isLoadingCustomers = true;
  bool isLoadingTransactions = true;
  String customersErrorMessage = '';
  String transactionsErrorMessage = '';

  List<Customer> upcomingDebts = [];
  List<Transaction> recentTransactions = [];

  @override
  void initState() {
    super.initState();
    _customerService = GetIt.I<CustomerService>();
    _transactionService = GetIt.I<TransactionService>();
    _fetchData();
  }

  Future<void> _fetchData() async {
    // Fetch data using the services
    final customersRes = await _customerService.getSoonPayment();
    final transactionsRes = await _transactionService.getTransactions(0, 5);
    customersRes.match(
      (failure) {
        setState(() {
          customersErrorMessage = 'فشل في تحميل البيانات';
          isLoadingCustomers = false;
        });
      },
      (customers) {
        setState(() {
          upcomingDebts = customers;
          isLoadingCustomers = false;
        });
      },
    );

    transactionsRes.match(
      (failure) {
        setState(() {
          transactionsErrorMessage = 'فشل في تحميل البيانات';
          isLoadingTransactions = false;
        });
      },
      (transactions) {
        setState(() {
          recentTransactions = transactions.data;
          isLoadingTransactions = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),

                // Quick Actions Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'إجراءات سريعة',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF003366),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildQuickActionCard(
                              icon: Icons.person_add,
                              title: 'إضافة مدين',
                              color: const Color(0xFF003366),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const CreateDebtPage(),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildQuickActionCard(
                              icon: Icons.receipt_long,
                              title: 'المعاملات',
                              color: Colors.green,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TransactionsPage(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildQuickActionCard(
                              icon: Icons.people,
                              title: 'قائمة المدينين',
                              color: Colors.orange,
                              onTap: () {
                                widget.onNavigateToDebts?.call();
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildQuickActionCard(
                              icon: Icons.analytics,
                              title: 'الإحصائيات',
                              color: Colors.purple,
                              onTap: () {
                                // Navigate to statistics
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Recent Transactions Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'المعاملات الأخيرة',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF003366),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                transactionsErrorMessage.isNotEmpty
                    ? SizedBox(
                        height: 140,
                        child: Center(child: Text(transactionsErrorMessage!)),
                      )
                    : SizedBox(
                        height: 140,
                        child: isLoadingTransactions
                            ? const Center(child: CircularProgressIndicator())
                            : ListView.builder(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                ),
                                itemCount: recentTransactions.length,
                                itemBuilder: (context, index) {
                                  final transaction = recentTransactions[index];
                                  return _buildTransactionCard(transaction);
                                },
                              ),
                      ),

                const SizedBox(height: 32),

                // Upcoming Debts Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'ديون تستحق قريباً',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF003366),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                customersErrorMessage.isNotEmpty
                    ? Center(
                        child: SizedBox(
                          height: 140,
                          child: Center(child: Text(customersErrorMessage!)),
                        ),
                      )
                    : isLoadingCustomers
                    ? Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        itemCount: upcomingDebts.length,
                        itemBuilder: (context, index) {
                          final debt = upcomingDebts[index];
                          return _buildUpcomingDebtCard(debt);
                        },
                      ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionCard(Transaction transaction) {
    final isDeposit = transaction.type == TransactionType.payment;
    return Container(
      width: 200,
      margin: const EdgeInsets.only(left: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDeposit
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isDeposit ? Icons.arrow_downward : Icons.arrow_upward,
                  color: isDeposit ? Colors.green : Colors.red,
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  isDeposit ? 'إيداع' : 'دين جديد',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            transaction.customerName ?? '',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF003366),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Text(
            '${transaction.amount.toStringAsFixed(0)} د.ع',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDeposit ? Colors.green : Colors.red,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            transaction.createdAt.toString(),
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingDebtCard(Customer debt) {
    final isUrgent =
        debt.paymentDue != null &&
        debt.paymentDue!.isBefore(DateTime.now().add(const Duration(days: 3)));
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUrgent
              ? Colors.red.withOpacity(0.3)
              : Colors.grey.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isUrgent
                  ? Colors.red.withOpacity(0.1)
                  : const Color(0xFF003366).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.calendar_today,
              color: isUrgent ? Colors.red : const Color(0xFF003366),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  debt.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF003366),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'الاستحقاق: ${debt.paymentDue!.toLocal().toString().split(' ')[0]}',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${debt.totalDebt.toStringAsFixed(0)} د.ع',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF003366),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isUrgent
                      ? Colors.red.withOpacity(0.1)
                      : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getDaysDifference(debt.paymentDue!),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isUrgent ? Colors.red : Colors.orange,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getDaysDifference(DateTime dueDate) {
    final now = DateTime.now();
    final difference = dueDate.difference(now).inDays;
    if (difference > 0) {
      return 'بعد $difference يوم';
    } else if (difference == 0) {
      return 'اليوم';
    } else {
      return 'منذ ${difference.abs()} يوم';
    }
  }
}
