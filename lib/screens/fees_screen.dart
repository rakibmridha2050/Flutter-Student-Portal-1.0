// fees_screen.dart
import 'package:flutter/material.dart';
import 'package:schoolportal/models/fee_data.dart';
import 'package:schoolportal/models/sample_fee_data.dart';



class FeesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final student = FeeDataRepository.getStudents().first; // Current student
    final feeSummary = FeeDataRepository.getFeeSummary(student.id);
    final recentPayments = FeeDataRepository.getPayments()
        .where((p) => p.studentId == student.id)
        .take(3)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Fees Management'),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Student Info Card
            _buildStudentInfoCard(student),
            SizedBox(height: 20),
            
            // Quick Stats
            _buildQuickStats(feeSummary),
            SizedBox(height: 20),
            
            // Fee Summary
            Text(
              'Fee Summary',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            ...feeSummary.map((summary) => _buildFeeSummaryCard(summary)).toList(),
            
            SizedBox(height: 20),
            
            // Recent Payments
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Payments',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text('View All'),
                ),
              ],
            ),
            ...recentPayments.map((payment) => _buildPaymentCard(payment)).toList(),
            
            SizedBox(height: 20),
            
            // Quick Actions
            Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            _buildQuickActions(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigate to payment screen
        },
        icon: Icon(Icons.payment),
        label: Text('Pay Fees'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildStudentInfoCard(Student student) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.green[100],
              child: Icon(Icons.person, size: 30, color: Colors.green),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text('Class: ${student.className} - Section ${student.section}'),
                  Text('Roll No: ${student.rollNumber}'),
                  Text('Parent: ${student.parentName}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats(List<FeeSummary> feeSummary) {
    final totalDue = feeSummary.fold(0.0, (sum, item) => sum + item.dueAmount);
    final totalPaid = feeSummary.fold(0.0, (sum, item) => sum + item.paidAmount);
    
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'Total Due',
            value: '₹${totalDue.toStringAsFixed(0)}',
            color: Colors.red,
            icon: Icons.money_off,
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: _buildStatCard(
            title: 'Total Paid',
            value: '₹${totalPaid.toStringAsFixed(0)}',
            color: Colors.green,
            icon: Icons.payment,
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: _buildStatCard(
            title: 'Pending Terms',
            value: '${feeSummary.where((item) => item.dueAmount > 0).length}',
            color: Colors.orange,
            icon: Icons.pending_actions,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeeSummaryCard(FeeSummary summary) {
    return Card(
      margin: EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  summary.term,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Chip(
                  label: Text(
                    summary.paymentStatus,
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: summary.statusColor,
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Fee',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    Text(
                      '₹${summary.totalFee.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Paid',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    Text(
                      '₹${summary.paidAmount.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Due',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    Text(
                      '₹${summary.dueAmount.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (summary.dueAmount > 0)
              Padding(
                padding: EdgeInsets.only(top: 10),
                child: ElevatedButton(
                  onPressed: () {},
                  child: Text('Pay Now'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    minimumSize: Size(double.infinity, 40),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentCard(Payment payment) {
    return Card(
      margin: EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getPaymentMethodIcon(payment.paymentMethod),
            color: Colors.green,
          ),
        ),
        title: Text(
          '₹${payment.amountPaid.toStringAsFixed(0)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(payment.term),
            Text(
              '${payment.paymentDate.day}/${payment.paymentDate.month}/${payment.paymentDate.year}',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        trailing: Chip(
          label: Text(payment.status),
          backgroundColor: payment.status == 'Completed'
              ? Colors.green.withOpacity(0.2)
              : Colors.orange.withOpacity(0.2),
        ),
        onTap: () {
          // View receipt
        },
      ),
    );
  }

  Widget _buildQuickActions() {
    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 2.5,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      children: [
        _buildActionButton(
          icon: Icons.receipt,
          label: 'View Receipts',
          color: Colors.blue,
        ),
        _buildActionButton(
          icon: Icons.history,
          label: 'Payment History',
          color: Colors.purple,
        ),
        _buildActionButton(
          icon: Icons.download,
          label: 'Download',
          color: Colors.orange,
        ),
        _buildActionButton(
          icon: Icons.help,
          label: 'Help & Support',
          color: Colors.red,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(icon, color: color),
              SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getPaymentMethodIcon(String method) {
    switch (method) {
      case 'Online Banking':
        return Icons.account_balance;
      case 'Credit Card':
        return Icons.credit_card;
      case 'Debit Card':
        return Icons.credit_card;
      case 'Cash':
        return Icons.money;
      case 'UPI':
        return Icons.payment;
      default:
        return Icons.payment;
    }
  }
}