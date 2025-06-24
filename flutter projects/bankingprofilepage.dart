import 'package:flutter/material.dart';

void main() {
  runApp(const MyBankingApp());
}

class AppColors {
  static const dominantBlue = Color.fromARGB(255, 255, 255, 255);
  static const lighterBlue = Color.fromARGB(253, 241, 240, 240);
  static const deepBlueDark = Color.fromARGB(255, 20, 40, 80);
  static const deeperBlue = Color.fromARGB(255, 30, 60, 100);
}

class MyBankingApp extends StatelessWidget {
  const MyBankingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Banking App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.dominantBlue,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.deeperBlue,
          foregroundColor: Colors.white,
        ),
        cardColor: AppColors.lighterBlue,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.deeperBlue,
            foregroundColor: Colors.white,
          ),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: AppColors.deepBlueDark),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const CustomerServicesPage(),
        '/request-card': (context) => RequestNewCardPage(),
        '/set-limits': (context) => CardLimitationsPage(),
        '/settings': (context) => const YonoSettingsPage(),
        '/change-pin': (context) => const ChangePinPage(),
        '/notifications': (context) => const NotificationSettingsPage(),
        '/language': (context) => const LanguageSettingsPage(),
        '/privacy': (context) => const PrivacySettingsPage(),
        '/update-profile': (context) => const UpdateProfilePage(),
      },
    );
  }
}

class ServiceItem {
  final String section;
  final String label;
  final IconData icon;
  final String? route;

  const ServiceItem({
    required this.section,
    required this.label,
    required this.icon,
    this.route,
  });
}

class CustomerServicesPage extends StatelessWidget {
  const CustomerServicesPage({super.key});

  final List<ServiceItem> services = const [
    ServiceItem(section: "Account Services", label: "Check Balance", icon: Icons.account_balance_wallet),
    ServiceItem(section: "Account Services", label: "View Statement", icon: Icons.receipt_long),
    ServiceItem(section: "Account Services", label: "Update Profile", icon: Icons.person, route: '/update-profile'),
    ServiceItem(section: "Card Services", label: "Block Debit Card", icon: Icons.block),
    ServiceItem(section: "Card Services", label: "Request New Card", icon: Icons.credit_card, route: '/request-card'),
    ServiceItem(section: "Card Services", label: "Set Card Limits", icon: Icons.tune, route: '/set-limits'),
    ServiceItem(section: "Support", label: "Contact Us", icon: Icons.support_agent),
    ServiceItem(section: "Support", label: "Raise a Complaint", icon: Icons.report_problem),
    ServiceItem(section: "Support", label: "Settings", icon: Icons.settings, route: '/settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final grouped = <String, List<ServiceItem>>{};
    for (var item in services) {
      grouped.putIfAbsent(item.section, () => []).add(item);
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Customer Services")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: grouped.entries.map((entry) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(entry.key, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ...entry.value.map((item) => Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: Icon(item.icon),
                  title: Text(item.label),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    if (item.route != null) Navigator.pushNamed(context, item.route!);
                  },
                ),
              )),
              const SizedBox(height: 20),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class RequestNewCardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Request New Card")),
      body: const Center(child: Text("Request New Card UI here")),
    );
  }
}

class CardLimitationsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Set Card Limits")),
      body: const Center(child: Text("Card Limitations UI here")),
    );
  }
}

class YonoSettingsPage extends StatelessWidget {
  const YonoSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SettingsTile(
            icon: Icons.lock,
            title: "Change PIN",
            onTap: () => Navigator.pushNamed(context, '/change-pin'),
          ),
          SettingsTile(
            icon: Icons.notifications,
            title: "Notification Preferences",
            onTap: () => Navigator.pushNamed(context, '/notifications'),
          ),
          SettingsTile(
            icon: Icons.language,
            title: "Language",
            onTap: () => Navigator.pushNamed(context, '/language'),
          ),
          SettingsTile(
            icon: Icons.privacy_tip,
            title: "Privacy & Security",
            onTap: () => Navigator.pushNamed(context, '/privacy'),
          ),
        ],
      ),
    );
  }
}

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.indigo),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}

class ChangePinPage extends StatelessWidget {
  const ChangePinPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Change PIN")),
      body: const Center(child: Text("Change PIN UI here")),
    );
  }
}

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool smsEnabled = true;
  bool emailEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notification Preferences")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text("SMS Notifications"),
            value: smsEnabled,
            onChanged: (val) => setState(() => smsEnabled = val),
          ),
          SwitchListTile(
            title: const Text("Email Notifications"),
            value: emailEnabled,
            onChanged: (val) => setState(() => emailEnabled = val),
          ),
        ],
      ),
    );
  }
}

class LanguageSettingsPage extends StatelessWidget {
  const LanguageSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Language")),
      body: const Center(child: Text("Choose your preferred language")),
    );
  }
}

class PrivacySettingsPage extends StatelessWidget {
  const PrivacySettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Privacy & Security")),
      body: const Center(child: Text("Privacy and security settings")),
    );
  }
}

class UpdateProfilePage extends StatelessWidget {
  const UpdateProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Update Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TextField(
              decoration: InputDecoration(labelText: 'Full Name'),
            ),
            const TextField(
              decoration: InputDecoration(labelText: 'Email Address'),
            ),
            const TextField(
              decoration: InputDecoration(labelText: 'Phone Number'),
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Simulate profile update logic
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Profile updated successfully!")),
                  );
                },
                child: const Text("Update Profile"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}