import 'package:flutter/material.dart';
import '../../widgets/sidebar_menu.dart';
import '../../widgets/dashboard_content.dart';
import '../../utils/app_colors.dart';
import '../../utils/responsive_helper.dart';
import '../user/user_management_screen.dart';
import '../vendor/vendor_list_screen.dart';
import '../product/product_list_screen.dart';
import '../order/order_list_screen.dart';
import '../report/reports_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  String selectedMenu = 'Dashboard';
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _onMenuSelected(String menu) {
    setState(() {
      selectedMenu = menu;
    });
    // Close drawer on mobile after selection
    if (ResponsiveHelper.isMobile(context) && _scaffoldKey.currentState?.isDrawerOpen == true) {
      Navigator.pop(context);
    }
  }

  Widget _getSelectedScreen() {
    switch (selectedMenu) {
      case 'User Management':
        return const UserManagementScreen();
      case 'Order Management':
        return const OrderListScreen();
      case 'Products':
        return const ProductListScreen();
      case 'Vendors':
        return const VendorListScreen();
      case 'Reports & Support':
        return const ReportsScreen();
      default:
        return DashboardContent(selectedMenu: selectedMenu);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.backgroundBeige,
      appBar: AppBar(
        title: Text(
          selectedMenu,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primaryBrown,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: isMobile ? Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ) : null,
        automaticallyImplyLeading: isMobile,
      ),
      drawer: isMobile ? SidebarMenu(
        selectedMenu: selectedMenu,
        onMenuSelected: _onMenuSelected,
      ) : null,
      body: Row(
        children: [
          // Sidebar for tablet/desktop
          if (!isMobile)
            SizedBox(
              width: 280,
              child: SidebarMenu(
                selectedMenu: selectedMenu,
                onMenuSelected: _onMenuSelected,
              ),
            ),
          // Main content
          Expanded(
            child: _getSelectedScreen(),
          ),
        ],
      ),
    );
  }
}
