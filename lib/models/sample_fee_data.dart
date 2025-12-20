// sample_fee_data.dart
import 'package:flutter/material.dart';
import 'package:schoolportal/models/fee_data.dart';

class FeeDataRepository {
  // Sample Students
  static List<Student> getStudents() {
    return [
      Student(
        id: 'S001',
        name: 'Rahul Sharma',
        className: '10th Grade',
        section: 'A',
        rollNumber: '101',
        parentName: 'Mr. Ramesh Sharma',
        contactNumber: '+91 9876543210',
        email: 'rahul.sharma@school.com',
      ),
      Student(
        id: 'S002',
        name: 'Priya Patel',
        className: '10th Grade',
        section: 'B',
        rollNumber: '102',
        parentName: 'Mrs. Sunita Patel',
        contactNumber: '+91 9876543211',
        email: 'priya.patel@school.com',
      ),
      Student(
        id: 'S003',
        name: 'Amit Kumar',
        className: '9th Grade',
        section: 'A',
        rollNumber: '201',
        parentName: 'Mr. Raj Kumar',
        contactNumber: '+91 9876543212',
        email: 'amit.kumar@school.com',
      ),
      Student(
        id: 'S004',
        name: 'Sneha Gupta',
        className: '11th Grade',
        section: 'C',
        rollNumber: '301',
        parentName: 'Mr. Sanjay Gupta',
        contactNumber: '+91 9876543213',
        email: 'sneha.gupta@school.com',
      ),
      Student(
        id: 'S005',
        name: 'Vikram Singh',
        className: '12th Grade',
        section: 'A',
        rollNumber: '401',
        parentName: 'Mr. Vijay Singh',
        contactNumber: '+91 9876543214',
        email: 'vikram.singh@school.com',
      ),
    ];
  }

  // Sample Fee Structure
  static List<FeeStructure> getFeeStructure() {
    final now = DateTime.now();
    return [
      FeeStructure(
        id: 'FS001',
        className: '10th Grade',
        term: 'Term 1 - 2024',
        tuitionFee: 25000,
        transportFee: 8000,
        labFee: 3000,
        libraryFee: 1500,
        sportsFee: 2000,
        activityFee: 2500,
        totalAmount: 42000,
        dueDate: DateTime(2024, 4, 15),
        lateFeePerDay: 50,
      ),
      FeeStructure(
        id: 'FS002',
        className: '10th Grade',
        term: 'Term 2 - 2024',
        tuitionFee: 25000,
        transportFee: 8000,
        labFee: 3000,
        libraryFee: 1500,
        sportsFee: 2000,
        activityFee: 2500,
        totalAmount: 42000,
        dueDate: DateTime(2024, 8, 15),
        lateFeePerDay: 50,
      ),
      FeeStructure(
        id: 'FS003',
        className: '9th Grade',
        term: 'Term 1 - 2024',
        tuitionFee: 22000,
        transportFee: 7000,
        labFee: 2500,
        libraryFee: 1500,
        sportsFee: 1500,
        activityFee: 2000,
        totalAmount: 36500,
        dueDate: DateTime(2024, 4, 15),
        lateFeePerDay: 40,
      ),
      FeeStructure(
        id: 'FS004',
        className: '11th Grade',
        term: 'Term 1 - 2024',
        tuitionFee: 28000,
        transportFee: 9000,
        labFee: 4000,
        libraryFee: 1500,
        sportsFee: 2000,
        activityFee: 2500,
        totalAmount: 47000,
        dueDate: DateTime(2024, 4, 15),
        lateFeePerDay: 60,
      ),
      FeeStructure(
        id: 'FS005',
        className: '12th Grade',
        term: 'Term 1 - 2024',
        tuitionFee: 30000,
        transportFee: 10000,
        labFee: 5000,
        libraryFee: 2000,
        sportsFee: 2500,
        activityFee: 3000,
        totalAmount: 52500,
        dueDate: DateTime(2024, 4, 15),
        lateFeePerDay: 70,
      ),
    ];
  }

  // Sample Payments
  static List<Payment> getPayments() {
    return [
      Payment(
        id: 'P001',
        studentId: 'S001',
        studentName: 'Rahul Sharma',
        className: '10th Grade',
        term: 'Term 1 - 2024',
        amountPaid: 42000,
        paymentDate: DateTime(2024, 4, 10),
        paymentMethod: 'Online Banking',
        transactionId: 'TXN00123456',
        status: 'Completed',
        receiptNumber: 'RCPT2024001',
        remarks: 'Paid in full',
      ),
      Payment(
        id: 'P002',
        studentId: 'S001',
        studentName: 'Rahul Sharma',
        className: '10th Grade',
        term: 'Term 2 - 2024',
        amountPaid: 21000,
        paymentDate: DateTime(2024, 8, 5),
        paymentMethod: 'Credit Card',
        transactionId: 'TXN00123457',
        status: 'Completed',
        receiptNumber: 'RCPT2024002',
        remarks: 'Partial payment',
      ),
      Payment(
        id: 'P003',
        studentId: 'S002',
        studentName: 'Priya Patel',
        className: '10th Grade',
        term: 'Term 1 - 2024',
        amountPaid: 42000,
        paymentDate: DateTime(2024, 4, 12),
        paymentMethod: 'Debit Card',
        transactionId: 'TXN00123458',
        status: 'Completed',
        receiptNumber: 'RCPT2024003',
      ),
      Payment(
        id: 'P004',
        studentId: 'S003',
        studentName: 'Amit Kumar',
        className: '9th Grade',
        term: 'Term 1 - 2024',
        amountPaid: 36500,
        paymentDate: DateTime(2024, 4, 20),
        paymentMethod: 'Cash',
        transactionId: 'TXN00123459',
        status: 'Completed',
        receiptNumber: 'RCPT2024004',
        remarks: 'Paid with ₹500 late fee',
      ),
      Payment(
        id: 'P005',
        studentId: 'S004',
        studentName: 'Sneha Gupta',
        className: '11th Grade',
        term: 'Term 1 - 2024',
        amountPaid: 23500,
        paymentDate: DateTime(2024, 4, 18),
        paymentMethod: 'Online Banking',
        transactionId: 'TXN00123460',
        status: 'Partial',
        receiptNumber: 'RCPT2024005',
        remarks: 'First installment',
      ),
    ];
  }

  // Sample Fee Dues
  static List<FeeDue> getFeeDues() {
    final now = DateTime.now();
    return [
      FeeDue(
        studentId: 'S001',
        studentName: 'Rahul Sharma',
        className: '10th Grade',
        term: 'Term 2 - 2024',
        totalDue: 42000,
        amountPaid: 21000,
        balance: 21000,
        dueDate: DateTime(2024, 8, 15),
        daysOverdue: now.isAfter(DateTime(2024, 8, 15)) 
            ? now.difference(DateTime(2024, 8, 15)).inDays 
            : 0,
        lateFee: 0,
      ),
      FeeDue(
        studentId: 'S002',
        studentName: 'Priya Patel',
        className: '10th Grade',
        term: 'Term 2 - 2024',
        totalDue: 42000,
        amountPaid: 0,
        balance: 42000,
        dueDate: DateTime(2024, 8, 15),
        daysOverdue: now.isAfter(DateTime(2024, 8, 15)) 
            ? now.difference(DateTime(2024, 8, 15)).inDays 
            : 0,
        lateFee: now.isAfter(DateTime(2024, 8, 15)) 
            ? now.difference(DateTime(2024, 8, 15)).inDays * 50 
            : 0,
      ),
      FeeDue(
        studentId: 'S004',
        studentName: 'Sneha Gupta',
        className: '11th Grade',
        term: 'Term 1 - 2024',
        totalDue: 47000,
        amountPaid: 23500,
        balance: 23500,
        dueDate: DateTime(2024, 4, 15),
        daysOverdue: now.difference(DateTime(2024, 4, 15)).inDays,
        lateFee: now.difference(DateTime(2024, 4, 15)).inDays * 60,
      ),
      FeeDue(
        studentId: 'S005',
        studentName: 'Vikram Singh',
        className: '12th Grade',
        term: 'Term 1 - 2024',
        totalDue: 52500,
        amountPaid: 0,
        balance: 52500,
        dueDate: DateTime(2024, 4, 15),
        daysOverdue: now.difference(DateTime(2024, 4, 15)).inDays,
        lateFee: now.difference(DateTime(2024, 4, 15)).inDays * 70,
      ),
    ];
  }

  // Sample Fee Summary for a student
  static List<FeeSummary> getFeeSummary(String studentId) {
    final payments = getPayments().where((p) => p.studentId == studentId).toList();
    final feeStructures = getFeeStructure();
    
    return [
      FeeSummary(
        term: 'Term 1 - 2024',
        totalFee: 42000,
        paidAmount: payments.where((p) => p.term == 'Term 1 - 2024').fold(0.0, (sum, p) => sum + p.amountPaid),
        dueAmount: 42000 - payments.where((p) => p.term == 'Term 1 - 2024').fold(0.0, (sum, p) => sum + p.amountPaid),
        paymentStatus: 'Paid',
        statusColor: Colors.green,
      ),
      FeeSummary(
        term: 'Term 2 - 2024',
        totalFee: 42000,
        paidAmount: payments.where((p) => p.term == 'Term 2 - 2024').fold(0.0, (sum, p) => sum + p.amountPaid),
        dueAmount: 42000 - payments.where((p) => p.term == 'Term 2 - 2024').fold(0.0, (sum, p) => sum + p.amountPaid),
        paymentStatus: 'Partial',
        statusColor: Colors.orange,
      ),
      FeeSummary(
        term: 'Term 3 - 2024',
        totalFee: 42000,
        paidAmount: 0,
        dueAmount: 42000,
        paymentStatus: 'Pending',
        statusColor: Colors.red,
      ),
    ];
  }

  // Get payment methods
  static List<String> getPaymentMethods() {
    return [
      'Online Banking',
      'Credit Card',
      'Debit Card',
      'Cash',
      'Cheque',
      'UPI',
      'Bank Transfer',
    ];
  }

  // Get fee breakdown for a specific term and class
  static Map<String, double> getFeeBreakdown(String className, String term) {
    final feeStructure = getFeeStructure().firstWhere(
      (fs) => fs.className == className && fs.term == term,
      orElse: () => getFeeStructure().first,
    );

    return {
      'Tuition Fee': feeStructure.tuitionFee,
      'Transport Fee': feeStructure.transportFee,
      'Lab Fee': feeStructure.labFee,
      'Library Fee': feeStructure.libraryFee,
      'Sports Fee': feeStructure.sportsFee,
      'Activity Fee': feeStructure.activityFee,
    };
  }
}