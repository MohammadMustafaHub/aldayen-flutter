import 'package:aldayen/services/stats_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart' as intl;

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  bool _isLoading = false;
  String? _errorMessage;

  double _totalDebt = 0.0;
  double _maxDebt = 0.0;
  double _minDebt = 0.0;
  double _averageDebt = 0.0;
  int _totalCustomers = 0;
  int _customersWithDebts = 0;
  int _upcomingDueDates = 0;
  int _overdueDebts = 0;
  String _maxDebtCustomerName = '-';
  String _minDebtCustomerName = '-';

  // Cache variables
  GetStatsResponse? _cachedResponse;
  DateTime? _lastFetchTime;
  static const Duration _cacheDuration = Duration(minutes: 5);

  // Number formatter for currency
  final intl.NumberFormat _currencyFormatter = intl.NumberFormat('#,###');

  @override
  void initState() {
    super.initState();
    _fetchStatistics();
  }

  Future<void> _fetchStatistics({bool forceRefresh = false}) async {
    // Check if we have cached data and it's still valid
    if (!forceRefresh &&
        _cachedResponse != null &&
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) < _cacheDuration) {
      // Use cached data
      _updateUIWithResponse(_cachedResponse!);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final statsService = GetIt.I<StatsService>();
      final response = await statsService.getStats();

      // Cache the response
      _cachedResponse = response;
      _lastFetchTime = DateTime.now();

      setState(() {
        _updateUIWithResponse(response);
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _errorMessage = 'فشل في تحميل الإحصائيات';
        _isLoading = false;
      });
    }
  }

  void _updateUIWithResponse(GetStatsResponse response) {
    _totalDebt = response.totalDebt;
    _maxDebt = response.maxDebt;
    _minDebt = response.minDebt;
    _totalCustomers = response.totalCustomers;
    _customersWithDebts = response.totalDebatedCustomers;
    _upcomingDueDates = response.soonDueDateDebt;
    _overdueDebts = response.overDueDateDebt;

    // Calculate average debt
    _averageDebt = _customersWithDebts > 0
        ? _totalDebt / _customersWithDebts
        : 0.0;

    // Note: The API doesn't provide customer names for min/max debt
    // You may need to add these fields to the API response
    _maxDebtCustomerName = '-';
    _minDebtCustomerName = '-';
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text(
            'الإحصائيات',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          backgroundColor: const Color(0xFF003366),
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(fontSize: 18, color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _fetchStatistics,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF003366),
                      ),
                      child: const Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: () => _fetchStatistics(forceRefresh: true),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Main Statistics Cards
                        _buildStatCard(
                          title: 'إجمالي الديون',
                          value:
                              '${_currencyFormatter.format(_totalDebt.toInt())} د.ع',
                          icon: Icons.account_balance_wallet,
                          color: const Color(0xFF003366),
                          subtitle: 'مجموع جميع الديون المستحقة',
                        ),
                        const SizedBox(height: 16),

                        // Two column stats
                        Row(
                          children: [
                            Expanded(
                              child: _buildSmallStatCard(
                                title: 'أعلى دين',
                                value:
                                    '${_currencyFormatter.format(_maxDebt.toInt())} د.ع',
                                icon: Icons.arrow_upward,
                                color: Colors.red,
                                subtitle: _maxDebtCustomerName,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildSmallStatCard(
                                title: 'أقل دين',
                                value:
                                    '${_currencyFormatter.format(_minDebt.toInt())} د.ع',
                                icon: Icons.arrow_downward,
                                color: Colors.green,
                                subtitle: _minDebtCustomerName,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Expanded(
                              child: _buildSmallStatCard(
                                title: 'متوسط الدين',
                                value:
                                    '${_currencyFormatter.format(_averageDebt.toInt())} د.ع',
                                icon: Icons.trending_flat,
                                color: Colors.orange,
                                subtitle: 'لكل مدين',
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildSmallStatCard(
                                title: 'عدد المدينين',
                                value: '$_customersWithDebts',
                                icon: Icons.people,
                                color: Colors.purple,
                                subtitle: 'من أصل $_totalCustomers',
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // Due Dates Section
                        const Text(
                          'تواريخ الاستحقاق',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF003366),
                          ),
                        ),
                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Expanded(
                              child: _buildDueDateCard(
                                title: 'قريبة الاستحقاق',
                                value: '$_upcomingDueDates',
                                icon: Icons.schedule,
                                color: Colors.amber,
                                subtitle: 'خلال 5 يوم',
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildDueDateCard(
                                title: 'متأخرة',
                                value: '$_overdueDebts',
                                icon: Icons.warning,
                                color: Colors.red,
                                subtitle: 'تجاوزت الموعد',
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // Summary Card
                        _buildSummaryCard(),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 36),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 28,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDueDateCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 40),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF003366),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF003366),
            const Color(0xFF003366).withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF003366).withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.insights,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                'ملخص الإحصائيات',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSummaryRow('إجمالي العملاء', '$_totalCustomers'),
          const Divider(color: Colors.white24, height: 24),
          _buildSummaryRow('العملاء المدينون', '$_customersWithDebts'),
          const Divider(color: Colors.white24, height: 24),
          _buildSummaryRow(
            'نسبة المدينين',
            _totalCustomers > 0
                ? '${((_customersWithDebts / _totalCustomers) * 100).toStringAsFixed(1)}%'
                : '0%',
          ),
          const Divider(color: Colors.white24, height: 24),
          _buildSummaryRow('الديون المتأخرة', '$_overdueDebts عميل'),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            color: Colors.white.withValues(alpha: 0.9),
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
