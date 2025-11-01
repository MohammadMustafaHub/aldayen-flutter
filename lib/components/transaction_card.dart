import 'package:flutter/material.dart';
import 'package:aldayen/models/transaction.dart';
import 'package:intl/intl.dart';

class TransactionCard extends StatelessWidget {
  final Transaction transaction;

  const TransactionCard({Key? key, required this.transaction})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isPayment = transaction.type == TransactionType.payment;
    final displayAmount = isPayment ? transaction.amount : -transaction.amount;
    final dateStr = DateFormat('dd/MM/yyyy').format(transaction.createdAt);
    final timeStr = DateFormat('hh:mm a').format(transaction.createdAt);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Icon based on transaction type
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isPayment
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isPayment ? Icons.arrow_downward : Icons.arrow_upward,
                color: isPayment ? Colors.green : Colors.red,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            // Transaction details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isPayment ? 'دفعة' : 'دين',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isPayment ? Colors.green : Colors.red,
                        ),
                      ),
                      Text(
                        '${displayAmount.abs().toStringAsFixed(0)} د.ع',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isPayment ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$dateStr - $timeStr',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
