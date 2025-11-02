class Transaction {
  final String id;
  final double amount;
  final DateTime createdAt;
  final TransactionType type;
  final String? customerName;
  Transaction({
    required this.id,
    required this.amount,
    required this.createdAt,
    required this.type,
    this.customerName,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      type: json['transactionType'] == 'Payment'
          ? TransactionType.payment
          : TransactionType.debit,
      customerName: json['customer']?['customerName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'createdAt': createdAt.toIso8601String(),
      'type': type == TransactionType.payment ? 'payment' : 'debit',
    };
  }
}

enum TransactionType { payment, debit }
