import 'package:flutter/material.dart';

class BankingHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Bank'),
        backgroundColor: Colors.indigo[300],
        actions: [
          IconButton(icon: Icon(Icons.notifications), onPressed: () {}),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBalanceCard(),
            SizedBox(height: 24),
            _buildQuickActions(),
            SizedBox(height: 32),
            Text('Recent Transactions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            Expanded(child: _buildTransactionList()),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.indigo[100],
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Available Balance',
                style: TextStyle(color: Colors.white70, fontSize: 16)),
            SizedBox(height: 8),
            Text('\$12,340.00',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _actionButton(Icons.send, 'Send'),
        _actionButton(Icons.qr_code_scanner, 'Receive'),
        _actionButton(Icons.receipt_long, 'Pay Bills'),
      ],
    );
  }

  Widget _actionButton(IconData icon, String label) {
    return Column(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: Colors.indigo[800],
          child: Icon(icon, color: Colors.white),
        ),
        SizedBox(height: 6),
        Text(label),
      ],
    );
  }

  Widget _buildTransactionList() {
    return ListView(
      children: [
        _transactionItem('Starbucks', '-\$8.50', 'Today'),
        _transactionItem('Amazon Purchase', '-\$112.00', 'Yesterday'),
        _transactionItem('Salary', '+\$2,000.00', 'May 25'),
        _transactionItem('Netflix', '-\$15.99', 'May 22'),
      ],
    );
  }

  Widget _transactionItem(String title, String amount, String date) {
    bool isIncome = amount.startsWith('+');
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isIncome ? Colors.green[100] : Colors.red[100],
        child: Icon(isIncome ? Icons.arrow_downward : Icons.arrow_upward,
            color: isIncome ? Colors.green.shade400 : Colors.red[800]),
      ),
      title: Text(title),
      subtitle: Text(date),
      trailing: Text(
        amount,
        style: TextStyle(
            color: isIncome ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold),
      ),
    );
  }
}