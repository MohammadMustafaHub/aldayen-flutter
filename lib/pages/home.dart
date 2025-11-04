import 'package:aldayen/pages/debts_list_page.dart';
import 'package:aldayen/pages/details.dart';
import 'package:aldayen/pages/settings.dart';
import 'package:aldayen/pages/subscription_ended_page.dart';
import 'package:aldayen/state-management/user-state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      DetailsPage(
        onNavigateToDebts: () {
          setState(() {
            _currentIndex = 1;
          });
        },
      ),
      const DebtsListPage(),
      const SettingsPage(),
    ];
  }

  bool _isSubscriptionExpired(UserState state) {
    if (state.user == null) return false;

    final subscriptionEndDate = state.user!.tenantInfo.subscriptionEndDate;
    final now = DateTime.now();

    print(state.user!.tenantInfo.subscriptionEndDate);
    print(now);

    return subscriptionEndDate.isBefore(now);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserCubit, UserState>(
      builder: (context, state) {
        // Check if subscription has expired
        if (_isSubscriptionExpired(state)) {
          return const SubscriptionEndedPage();
        }

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            backgroundColor: Colors.white,

            body: _pages[_currentIndex],
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              selectedItemColor: const Color(0xFF003366),
              unselectedItemColor: Colors.grey,
              backgroundColor: Colors.white,
              type: BottomNavigationBarType.fixed,
              elevation: 8,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'الرئيسية',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.account_balance_wallet),
                  label: 'الديون',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings),
                  label: 'الإعدادات',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
