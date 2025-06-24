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
  void navigate(BuildContext context, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ServiceDetailPage(serviceName: title),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Account Services")),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          serviceTile(context, "Check Balance", Icons.account_balance_wallet),
          serviceTile(context, "View Statement", Icons.receipt_long),
          serviceTile(context, "Update Profile", Icons.person),
        ],
      ),
    );
  }

  Widget serviceTile(BuildContext context, String title, IconData icon) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, color: Colors.deepPurple),
        title: Text(title),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => navigate(context, title),
      ),
    );
  }
}

class ServiceDetailPage extends StatelessWidget {
  final String serviceName;

  const ServiceDetailPage({Key? key, required this.serviceName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(serviceName),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context), // Popping the route
        ),
      ),
      body: Center(
        child: Text(
          "$serviceName Page Content",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}