import 'package:aldayen/models/transaction.dart';

class Customer {
  final String id;
  final String name;
  final String? phoneNumber;
  final String? note;
  final DateTime? paymentDue;
  final double totalDebt;

  Customer({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.note,
    required this.paymentDue,
    required this.totalDebt,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] as String,
      name: json['name'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      note: json['note'] as String?,
      paymentDue: json['paymentDue'] != null
          ? DateTime.parse(json['paymentDue'] as String)
          : null,
      totalDebt: (json['totalDebt'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'note': note,
      'paymentDue': paymentDue?.toIso8601String(),
      'totalDebt': totalDebt,
    };
  }
}


class CustomerWithTransactions {
  final Customer customer;
  final List<Transaction> transactions;

  CustomerWithTransactions({
    required this.customer,
    required this.transactions,
  });

  factory CustomerWithTransactions.fromJson(Map<String, dynamic> json) {
    final transactionsJson = json['transactions'] as List<dynamic>;

    return CustomerWithTransactions(
      customer: Customer.fromJson(json),
      transactions: transactionsJson
          .map((e) => Transaction.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customer': customer.toJson(),
      'transactions': transactions.map((e) => e.toJson()).toList(),
    };
  }
}