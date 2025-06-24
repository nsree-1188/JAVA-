import 'package:flutter/material.dart';

void main() => runApp(AccountServicesApp());

class AccountServicesApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Account Services',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: AccountServicesPage(),
    );
  }
}

class AccountServicesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Account Services")),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          serviceTile("Check Balance", Icons.account_balance_wallet),
          serviceTile("View Statement", Icons.receipt_long),
          serviceTile("Update Profile", Icons.person),
        ],
      ),
    );
  }

  Widget serviceTile(String title, IconData icon) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Icon(icon, color: Colors.deepPurple),
        title: Text(title),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {},
      ),
    );
  }
}