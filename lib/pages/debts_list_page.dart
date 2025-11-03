import 'package:aldayen/models/customer.dart';
import 'package:aldayen/pages/debts-management/create_debt.dart';
import 'package:aldayen/pages/debts-management/update_debt.dart';
import 'package:aldayen/services/customer_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class DebtsListPage extends StatefulWidget {
  const DebtsListPage({super.key});

  @override
  State<DebtsListPage> createState() => _DebtsListPageState();
}

class _DebtsListPageState extends State<DebtsListPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final CustomerService _customerService;
  List<Customer> _customers = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _errorMessage;
  int _currentPage = 0;
  bool _hasMore = true;
  final int _pageSize = 20;
  String _searchQuery = '';
  OrderBy _currentOrderBy = OrderBy.none;

  @override
  void initState() {
    super.initState();
    _customerService = GetIt.I<CustomerService>();
    _scrollController.addListener(_onScroll);
    _fetchCustomers();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore && _hasMore) {
        _loadMoreCustomers();
      }
    }
  }

  Future<void> _fetchCustomers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _currentPage = 0;
      _customers = [];
    });

    final result = await _customerService.fetchCustomers(
      _currentPage,
      _pageSize,
      _searchQuery.isEmpty ? null : _searchQuery,
      _currentOrderBy,
    );

    result.match(
      (error) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'فشل في تحميل قائمة العملاء';
        });
      },
      (paginatedResponse) {
        setState(() {
          _customers = paginatedResponse.data;
          _hasMore = paginatedResponse.hasNext;
          _isLoading = false;
        });
      },
    );
  }

  Future<void> _loadMoreCustomers() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    final nextPage = _currentPage + 1;
    final result = await _customerService.fetchCustomers(
      nextPage,
      _pageSize,
      _searchQuery.isEmpty ? null : _searchQuery,
      _currentOrderBy,
    );

    result.match(
      (error) {
        setState(() {
          _isLoadingMore = false;
        });
      },
      (paginatedResponse) {
        setState(() {
          _customers.addAll(paginatedResponse.data);
          _currentPage = nextPage;
          _hasMore = paginatedResponse.hasNext;
          _isLoadingMore = false;
        });
      },
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle bar
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Title
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        children: [
                          Icon(
                            Icons.filter_list,
                            color: Color(0xFF003366),
                            size: 24,
                          ),
                          SizedBox(width: 12),
                          Text(
                            'ترتيب حسب',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF003366),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Filter Options
                    _buildFilterOption(
                      'الأحدث',
                      OrderBy.none,
                      Icons.new_releases_outlined,
                    ),
                    _buildFilterOption(
                      'تاريخ الاستحقاق (الأقرب أولاً)',
                      OrderBy.dueDateAsc,
                      Icons.calendar_today,
                    ),
                    _buildFilterOption(
                      'تاريخ الاستحقاق (الأبعد أولاً)',
                      OrderBy.dueDateDesc,
                      Icons.calendar_today_outlined,
                    ),
                    _buildFilterOption(
                      'المبلغ (من الأقل إلى الأكثر)',
                      OrderBy.amountAsc,
                      Icons.arrow_upward,
                    ),
                    _buildFilterOption(
                      'المبلغ (من الأكثر إلى الأقل)',
                      OrderBy.amountDesc,
                      Icons.arrow_downward,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterOption(String label, OrderBy orderBy, IconData icon) {
    final isSelected = _currentOrderBy == orderBy;
    return InkWell(
      onTap: () {
        setState(() {
          _currentOrderBy = orderBy;
        });
        _fetchCustomers();
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF003366).withValues(alpha: 0.1) : null,
          border: Border(
            right: BorderSide(
              color: isSelected ? const Color(0xFF003366) : Colors.transparent,
              width: 4,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF003366) : Colors.grey[600],
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? const Color(0xFF003366)
                      : Colors.grey[800],
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF003366),
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        body: SafeArea(
          child: Column(
            children: [
              // Header Section
              Container(
                padding: const EdgeInsets.all(24),
                color: Colors.grey[50],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'قائمة الديون',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF003366),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Search Bar with Filter Button
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Search Field
                        Expanded(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeInOut,
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _searchController,
                              style: const TextStyle(fontSize: 16),
                              decoration: InputDecoration(
                                hintText: 'ابحث بالاسم أو رقم الهاتف...',
                                hintStyle: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 15,
                                ),
                                prefixIcon: const Icon(
                                  Icons.search,
                                  color: Color(0xFF003366),
                                ),
                                suffixIcon: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (_searchController.text.isNotEmpty)
                                      IconButton(
                                        icon: const Icon(
                                          Icons.close_rounded,
                                          color: Colors.grey,
                                        ),
                                        onPressed: () {
                                          _searchController.clear();
                                          _searchQuery = '';
                                          _fetchCustomers();
                                          setState(() {});
                                        },
                                      ),
                                  ],
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF003366),
                                    width: 1.5,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 14,
                                ),
                              ),
                              onSubmitted: (value) {
                                _searchQuery = value;
                                _fetchCustomers();
                              },
                              onChanged: (value) {
                                setState(() {});
                              },
                            ),
                          ),
                        ),

                        const SizedBox(width: 10),

                        // Filter Button
                        Container(
                          height: 46,
                          width: 46,
                          decoration: BoxDecoration(
                            color: _currentOrderBy != OrderBy.none
                                ? const Color(0xFF003366)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.grey.withValues(alpha: 0.2),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.filter_list_rounded,
                              color: _currentOrderBy != OrderBy.none
                                  ? Colors.white
                                  : Colors.grey[700],
                              size: 24,
                            ),
                            onPressed: _showFilterBottomSheet,
                            tooltip: 'تصفية النتائج',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // List of Debtors
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _errorMessage!,
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _fetchCustomers,
                              child: const Text('إعادة المحاولة'),
                            ),
                          ],
                        ),
                      )
                    : _customers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.account_balance_wallet_outlined,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'لا توجد ديون',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 8,
                        ),
                        itemCount: _customers.length + (_isLoadingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == _customers.length) {
                            return const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          final customer = _customers[index];
                          return _buildDebtorCard(customer);
                        },
                      ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CreateDebtPage()),
            );
            // Refresh the list after returning from create page
            _fetchCustomers();
          },
          backgroundColor: const Color(0xFF003366),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildDebtorCard(Customer customer) {
    final bool isOverdue =
        customer.paymentDue != null &&
        customer.paymentDue!.isBefore(DateTime.now());

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOverdue
              ? Colors.red.withValues(alpha: 0.3)
              : Colors.grey.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UpdateDebtPage(debtId: customer.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name and Avatar Row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF003366).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.person,
                    color: const Color(0xFF003366),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF003366),
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (customer.phoneNumber != null)
                        Row(
                          children: [
                            Icon(
                              Icons.phone,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 6),
                            Text(
                              customer.phoneNumber!,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Amount and Due Date Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Amount
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'المبلغ',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${customer.totalDebt.toStringAsFixed(0)} د.ع',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF003366),
                      ),
                    ),
                  ],
                ),
                // Due Date with Badge
                if (customer.paymentDue != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: isOverdue ? Colors.red : Colors.grey[600],
                          ),
                          const SizedBox(width: 6),
                          Text(
                            customer.paymentDue!.toString().split(' ')[0],
                            style: TextStyle(
                              fontSize: 13,
                              color: isOverdue ? Colors.red : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      if (isOverdue) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'متأخر',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
