import 'package:flutter/material.dart';

void main() {
  runApp(AccountServicesApp());
}

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

// ---------------- Account Services Home Page ----------------

class AccountServicesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Account Services")),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          serviceTile(context, "Check Balance", Icons.account_balance_wallet),
          serviceTile(context, "View Statement", Icons.receipt_long),
          serviceTile(context, "Update Profile", Icons.person, isProfile: true),
        ],
      ),
    );
  }

  Widget serviceTile(BuildContext context, String title, IconData icon, {bool isProfile = false}) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, color: Colors.deepPurple),
        title: Text(title),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          if (isProfile) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => UpdateProfilePage()));
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ServiceDetailPage(serviceName: title),
              ),
            );
          }
        },
      ),
    );
  }
}

// ---------------- Generic Detail Page ----------------

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
          onPressed: () => Navigator.pop(context),
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

// ---------------- Update Profile Page ----------------

class UpdateProfilePage extends StatefulWidget {
  @override
  _UpdateProfilePageState createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends State<UpdateProfilePage> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String email = '';
  String phone = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Update Profile"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              buildTextField("Full Name", Icons.person, (val) => name = val,
                      (val) => val!.isEmpty ? "Name is required" : null),
              SizedBox(height: 16),
              buildTextField("Email", Icons.email, (val) => email = val,
                      (val) => val!.contains('@') ? null : "Enter valid email"),
              SizedBox(height: 16),
              buildTextField("Phone", Icons.phone, (val) => phone = val,
                      (val) => val!.length == 10 ? null : "Enter 10 digit phone"),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Profile Updated Successfully")),
                    );
                    Navigator.pop(context); // Go back to home
                  }
                },
                child: Text("Save Changes"),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: Colors.deepPurple,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(
      String label,
      IconData icon,
      Function(String) onSaved,
      String? Function(String?) validator,
      ) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onSaved: (val) => onSaved(val!),
      validator: validator,
    );
  }
}