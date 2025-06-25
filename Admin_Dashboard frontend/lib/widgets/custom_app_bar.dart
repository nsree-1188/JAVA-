import 'package:flutter/material.dart';
import '../screens/profile/update_admin_profile_screen.dart';
import '../screens/profile/change_password_screen.dart';
import '../services/auth_service.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBar({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: [
        PopupMenuButton<String>(
          icon: const CircleAvatar(
            child: Icon(Icons.person),
          ),
          onSelected: (value) async {
            switch (value) {
              case 'profile':
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UpdateAdminProfileScreen(),
                  ),
                );
                break;
              case 'password':
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChangePasswordScreen(),
                  ),
                );
                break;
              case 'logout':
                await AuthService.logout();
                if (context.mounted) {
                  Navigator.of(context).pushReplacementNamed('/login');
                }
                break;
            }
          },
          itemBuilder: (BuildContext context) => [
            const PopupMenuItem<String>(
              value: 'profile',
              child: ListTile(
                leading: Icon(Icons.person),
                title: Text('Update Profile'),
              ),
            ),
            const PopupMenuItem<String>(
              value: 'password',
              child: ListTile(
                leading: Icon(Icons.lock),
                title: Text('Change Password'),
              ),
            ),
            const PopupMenuItem<String>(
              value: 'logout',
              child: ListTile(
                leading: Icon(Icons.logout),
                title: Text('Logout'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
