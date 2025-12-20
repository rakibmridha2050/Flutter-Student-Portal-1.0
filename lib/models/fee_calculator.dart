// fee_calculator.dart
import 'package:schoolportal/models/fee_data.dart';

class FeeCalculator {
  static double calculateTotalWithLateFee(FeeDue feeDue) {
    return feeDue.balance + feeDue.lateFee;
  }

  static double calculatePendingAmount(List<FeeSummary> summaries) {
    return summaries.fold(0.0, (sum, item) => sum + item.dueAmount);
  }

  static double calculateTotalPaid(List<Payment> payments) {
    return payments.fold(0.0, (sum, item) => sum + item.amountPaid);
  }

  static String formatCurrency(double amount) {
    return '₹${amount.toStringAsFixed(2)}';
  }

  static String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}