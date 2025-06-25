import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../services/auth_service.dart';

class SidebarMenu extends StatelessWidget {
  final String selectedMenu;
  final Function(String) onMenuSelected;

  const SidebarMenu({
    super.key,
    required this.selectedMenu,
    required this.onMenuSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryBrown,
                    AppColors.lightBrown,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.backgroundBeige,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.admin_panel_settings,
                        color: AppColors.primaryBrown,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Admin Panel',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Menu Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 20),
                children: [
                  _buildMenuItem(
                    icon: Icons.dashboard,
                    title: 'Dashboard',
                    isSelected: selectedMenu == 'Dashboard',
                  ),
                  _buildMenuItem(
                    icon: Icons.people,
                    title: 'User Management',
                    isSelected: selectedMenu == 'User Management',
                  ),
                  _buildMenuItem(
                    icon: Icons.shopping_cart,
                    title: 'Order Management',
                    isSelected: selectedMenu == 'Order Management',
                  ),
                  _buildMenuItem(
                    icon: Icons.inventory,
                    title: 'Products',
                    isSelected: selectedMenu == 'Products',
                  ),
                  _buildMenuItem(
                    icon: Icons.store,
                    title: 'Vendors',
                    isSelected: selectedMenu == 'Vendors',
                  ),
                  _buildMenuItem(
                    icon: Icons.report,
                    title: 'Reports & Support',
                    isSelected: selectedMenu == 'Reports & Support',
                  ),
                ],
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Divider(),
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primaryBrown,
                      child: const Text(
                        'A',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    title: const Text(
                      'Admin User',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: const Text('admin@example.com'),
                  ),
                  const SizedBox(height: 10),
                  // Alternative: Direct logout button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _handleLogout(context),
                      icon: const Icon(Icons.logout, size: 18),
                      label: const Text('Logout'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade50,
                        foregroundColor: Colors.red.shade700,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: Colors.red.shade200),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required bool isSelected,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? AppColors.primaryBrown : AppColors.textSecondary,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? AppColors.primaryBrown : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        selectedTileColor: AppColors.backgroundBeige,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        onTap: () => onMenuSelected(title),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    // Show confirmation dialog
    final bool? shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      try {
        // Show loading indicator
        if (context.mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Perform logout
        await AuthService.logout();

        // Navigate to login screen and clear all previous routes
        if (context.mounted) {
          Navigator.of(context).pop(); // Close loading dialog
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/login',
                (route) => false,
          );
        }
      } catch (e) {
        // Handle logout error
        if (context.mounted) {
          Navigator.of(context).pop(); // Close loading dialog
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Logout failed: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
