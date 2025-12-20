// fee_data.dart
import 'dart:ui';

class Student {
  final String id;
  final String name;
  final String className;
  final String section;
  final String rollNumber;
  final String parentName;
  final String contactNumber;
  final String email;

  Student({
    required this.id,
    required this.name,
    required this.className,
    required this.section,
    required this.rollNumber,
    required this.parentName,
    required this.contactNumber,
    required this.email,
  });
}

class FeeStructure {
  final String id;
  final String className;
  final String term;
  final double tuitionFee;
  final double transportFee;
  final double labFee;
  final double libraryFee;
  final double sportsFee;
  final double activityFee;
  final double totalAmount;
  final DateTime dueDate;
  final double lateFeePerDay;

  FeeStructure({
    required this.id,
    required this.className,
    required this.term,
    required this.tuitionFee,
    required this.transportFee,
    required this.labFee,
    required this.libraryFee,
    required this.sportsFee,
    required this.activityFee,
    required this.totalAmount,
    required this.dueDate,
    required this.lateFeePerDay,
  });
}

class Payment {
  final String id;
  final String studentId;
  final String studentName;
  final String className;
  final String term;
  final double amountPaid;
  final DateTime paymentDate;
  final String paymentMethod;
  final String transactionId;
  final String status;
  final String receiptNumber;
  final String? remarks;

  Payment({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.className,
    required this.term,
    required this.amountPaid,
    required this.paymentDate,
    required this.paymentMethod,
    required this.transactionId,
    required this.status,
    required this.receiptNumber,
    this.remarks,
  });
}

class FeeDue {
  final String studentId;
  final String studentName;
  final String className;
  final String term;
  final double totalDue;
  final double amountPaid;
  final double balance;
  final DateTime dueDate;
  final int daysOverdue;
  final double lateFee;

  FeeDue({
    required this.studentId,
    required this.studentName,
    required this.className,
    required this.term,
    required this.totalDue,
    required this.amountPaid,
    required this.balance,
    required this.dueDate,
    required this.daysOverdue,
    required this.lateFee,
  });
}

class FeeSummary {
  final String term;
  final double totalFee;
  final double paidAmount;
  final double dueAmount;
  final String paymentStatus;
  final Color statusColor;

  FeeSummary({
    required this.term,
    required this.totalFee,
    required this.paidAmount,
    required this.dueAmount,
    required this.paymentStatus,
    required this.statusColor,
  });
}