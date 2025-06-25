import 'package:flutter/material.dart';
import '../../widgets/custom_app_bar.dart';
import 'vendor_list_screen.dart';

class VendorManagementScreen extends StatelessWidget {
  const VendorManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // This screen redirects to VendorListScreen as per requirements
    return const VendorListScreen();
  }
}
