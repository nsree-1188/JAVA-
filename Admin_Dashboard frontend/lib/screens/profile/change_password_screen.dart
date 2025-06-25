import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_app_bar.dart';
import '../../utils/helpers.dart';
import '../../utils/app_colors.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await AuthService.changePassword(
        _currentPasswordController.text.trim(),
        _newPasswordController.text.trim(),
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (success) {
          Helpers.showSnackBar(context, 'Password changed successfully');
          Navigator.pop(context);
        } else {
          Helpers.showSnackBar(context, 'Failed to change password. Please check your current password.', isError: true);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        Helpers.showSnackBar(context, 'Error changing password: $e', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBeige,
      appBar: AppBar(
        title: const Text(
          'Change Password',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primaryBrown,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.lightBrown.withOpacity(0.1),
                      AppColors.backgroundBeige,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryBrown.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Card(
                  elevation: 0,
                  color: Colors.transparent,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primaryBrown,
                                    AppColors.lightBrown,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.lock,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Change Password',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryBrown,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Please enter your current password and choose a new secure password.',
                          style: TextStyle(
                            color: AppColors.primaryBrown.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Current Password
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.primaryBrown.withOpacity(0.1),
                            ),
                          ),
                          child: TextFormField(
                            controller: _currentPasswordController,
                            obscureText: !_showCurrentPassword,
                            decoration: InputDecoration(
                              labelText: 'Current Password',
                              labelStyle: TextStyle(color: AppColors.primaryBrown),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              prefixIcon: Icon(Icons.lock_outline, color: AppColors.primaryBrown),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _showCurrentPassword ? Icons.visibility_off : Icons.visibility,
                                  color: AppColors.primaryBrown,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _showCurrentPassword = !_showCurrentPassword;
                                  });
                                },
                              ),
                              filled: true,
                              fillColor: Colors.transparent,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your current password';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 16),

                        // New Password
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.primaryBrown.withOpacity(0.1),
                            ),
                          ),
                          child: TextFormField(
                            controller: _newPasswordController,
                            obscureText: !_showNewPassword,
                            decoration: InputDecoration(
                              labelText: 'New Password',
                              labelStyle: TextStyle(color: AppColors.primaryBrown),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              prefixIcon: Icon(Icons.lock, color: AppColors.primaryBrown),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _showNewPassword ? Icons.visibility_off : Icons.visibility,
                                  color: AppColors.primaryBrown,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _showNewPassword = !_showNewPassword;
                                  });
                                },
                              ),
                              filled: true,
                              fillColor: Colors.transparent,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter a new password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Confirm Password
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.primaryBrown.withOpacity(0.1),
                            ),
                          ),
                          child: TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: !_showConfirmPassword,
                            decoration: InputDecoration(
                              labelText: 'Confirm New Password',
                              labelStyle: TextStyle(color: AppColors.primaryBrown),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              prefixIcon: Icon(Icons.lock, color: AppColors.primaryBrown),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _showConfirmPassword ? Icons.visibility_off : Icons.visibility,
                                  color: AppColors.primaryBrown,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _showConfirmPassword = !_showConfirmPassword;
                                  });
                                },
                              ),
                              filled: true,
                              fillColor: Colors.transparent,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please confirm your new password';
                              }
                              if (value != _newPasswordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Password Requirements
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.infoColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.infoColor.withOpacity(0.2)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Password Requirements:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryBrown,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '• At least 6 characters long\n'
                                    '• Include uppercase and lowercase letters\n'
                                    '• Include at least one number\n'
                                    '• Include at least one special character',
                                style: TextStyle(
                                  color: AppColors.primaryBrown.withOpacity(0.8),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Change Password Button
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryBrown,
                      AppColors.lightBrown,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryBrown.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _changePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Changing Password...',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  )
                      : const Text(
                    'Change Password',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
