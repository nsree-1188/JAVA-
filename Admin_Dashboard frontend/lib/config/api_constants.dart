import 'dart:io';

class ApiConstants {
  // Use 10.0.2.2 for Android emulator, localhost for others
  static String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3007/api';
    } else {
      return 'http://localhost:3007/api';
    }
  }

  // Authentication endpoints
  static String get login => '$baseUrl/auth/login';
  static String get register => '$baseUrl/auth/register';
  static String get refreshToken => '$baseUrl/auth/refresh';
  static String get changePassword => '$baseUrl/admin/change-password';

  // Dashboard
  static String get dashboardStats => '$baseUrl/admin/dashboard-stats';

  // User Management
  static String get users => '$baseUrl/users';
  static String userById(String id) => '$users/$id';

  // Vendor Management
  static String get vendors => '$baseUrl/vendors';
  static String vendorById(String id) => '$vendors/$id';

  // Admin Products
  static String get adminProducts => '$baseUrl/admin/products';
  static String adminProductById(String id) => '$adminProducts/$id';

  // Vendor Products
  static String get vendorProducts => '$baseUrl/vendor/products';
  static String vendorProductById(String id) => '$vendorProducts/$id';

  // Legacy Products endpoint (for backward compatibility)
  static String get products => '$baseUrl/products';
  static String productById(String id) => '$products/$id';
  static String vendorProductsLegacy(String vendorId) => '$products/vendor/$vendorId';

  // Orders
  static String get orders => '$baseUrl/orders';
  static String orderById(String id) => '$orders/$id';

  // Reports
  static String get reports => '$baseUrl/reports';
  static String reportById(String id) => '$reports/$id';

  // Size Management
  static String get sizeCategories => '$baseUrl/size-categories';
  static String sizesByCategory(String category) => '$baseUrl/sizes/$category';
}
