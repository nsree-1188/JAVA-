import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../config/api_constants.dart';
import '../models/user_model.dart';
import '../models/vendor_model.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';
import '../models/report_model.dart';
import '../models/dashboard_stats.dart';

class ApiService {
  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
  };

  // Static list to store vendors for demo purposes
  static List<VendorModel> _mockVendorsList = [];
  static bool _isInitialized = false;

  // Initialize mock data if not already done
  static void _initializeMockData() {
    if (!_isInitialized) {
      _mockVendorsList = _getInitialMockVendors();
      _isInitialized = true;
      print('Mock data initialized with ${_mockVendorsList.length} vendors');
    }
  }

  // Force initialization for testing
  static void forceInitializeMockData() {
    if (!_isInitialized) {
      _initializeMockData();
    }
    print('Mock data status: initialized: $_isInitialized');
  }

  // Dashboard Statistics
  static Future<DashboardStats> getDashboardStats() async {
    try {
      print('🔍 Fetching dashboard stats from: ${ApiConstants.dashboardStats}');

      final response = await http.get(
        Uri.parse(ApiConstants.dashboardStats),
        headers: _headers,
      );

      print('📊 Dashboard stats response status: ${response.statusCode}');
      print('📊 Dashboard stats response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        // Handle both response formats
        final statsData = responseData['success'] == true
            ? responseData['stats']
            : responseData;

        print('✅ Dashboard stats parsed successfully');
        return DashboardStats.fromJson(statsData);
      } else {
        print('⚠️ Dashboard stats API failed, using mock data');
        return _getMockDashboardStats();
      }
    } catch (e) {
      print('❌ Error fetching dashboard stats: $e');
      return _getMockDashboardStats();
    }
  }

  // User Management
  static Future<List<UserModel>> getUsers() async {
    try {
      print('🔍 Fetching users from: ${ApiConstants.users}');

      final response = await http.get(
        Uri.parse(ApiConstants.users),
        headers: _headers,
      );

      print('👥 Users response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        // Handle both response formats
        final List<dynamic> usersData = responseData['success'] == true
            ? responseData['users']
            : responseData;

        return usersData.map((json) => UserModel.fromJson(json)).toList();
      } else {
        print('⚠️ Users API failed, using mock data');
        return _getMockUsers();
      }
    } catch (e) {
      print('❌ Error fetching users: $e');
      return _getMockUsers();
    }
  }

  // Vendor Management
  static Future<List<VendorModel>> getVendors() async {
    try {
      print('🔍 Fetching vendors from: ${ApiConstants.vendors}');

      final response = await http.get(
        Uri.parse(ApiConstants.vendors),
        headers: _headers,
      );

      print('🏪 Vendors response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        // Handle both response formats
        final List<dynamic> vendorsData = responseData['success'] == true
            ? responseData['vendors']
            : responseData;

        return vendorsData.map((json) => VendorModel.fromJson(json)).toList();
      } else {
        print('⚠️ Vendors API failed, using mock data');
        _initializeMockData();
        return List.from(_mockVendorsList);
      }
    } catch (e) {
      print('❌ Error fetching vendors: $e');
      _initializeMockData();
      return List.from(_mockVendorsList);
    }
  }

  static Future<bool> updateVendorStatus(String vendorId, String status) async {
    try {
      final response = await http.put(
        Uri.parse(ApiConstants.vendorById(vendorId)),
        headers: _headers,
        body: json.encode({'status': status}),
      );

      return response.statusCode == 200;
    } catch (e) {
      return true; // Return true for demo purposes
    }
  }

  // ADMIN PRODUCTS MANAGEMENT (from admin_products table)
  static Future<List<ProductModel>> getAdminProducts() async {
    try {
      print('🔍 Fetching admin products from: ${ApiConstants.adminProducts}');

      final response = await http.get(
        Uri.parse(ApiConstants.adminProducts),
        headers: _headers,
      );

      print('🏢 Admin Products API Response Status: ${response.statusCode}');
      print('🏢 Admin Products API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);

        List<dynamic> productsData;
        if (responseData['success'] == true) {
          productsData = responseData['products'];
        } else if (responseData is List) {
          productsData = responseData;
        } else if (responseData is Map && responseData.containsKey('products')) {
          productsData = responseData['products'];
        } else {
          print('❌ Unexpected admin products response format: $responseData');
          return [];
        }

        final adminProducts = productsData.map((json) {
          print('🔄 Processing admin product JSON: $json');

          // Map backend fields to frontend model
          json['vendorId'] = 'admin';
          json['vendorName'] = 'Admin Store';

          // Map stock_quantity to stock for consistency
          if (json['stock_quantity'] != null) {
            json['stock'] = json['stock_quantity'];
          }

          // Handle images - DON'T overwrite if images array already exists
          print('🖼️ Original images field: ${json['images']}');
          print('🖼️ Original image_url field: ${json['image_url']}');

          if (json['images'] == null || (json['images'] is List && json['images'].isEmpty)) {
            // Only set images from image_url if images array is null or empty
            if (json['image_url'] != null && json['image_url'].toString().isNotEmpty) {
              json['images'] = [
                'http://10.0.2.2:3005/uploads/${json['image_url']}'
              ];
              print('🖼️ Set images from image_url: ${json['images']}');
            } else {
              json['images'] = [];
              print('🖼️ Set empty images array');
            }
          } else {
            print('🖼️ Using existing images array: ${json['images']}');
          }

          return ProductModel.fromJson(json);
        }).toList();

        print('✅ Successfully parsed ${adminProducts.length} admin products from API');

        // Debug: Print first product's images
        if (adminProducts.isNotEmpty) {
          print('🖼️ First admin product images: ${adminProducts.first.images}');
        }

        return adminProducts;
      } else {
        print('❌ Admin products API call failed with status: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Error fetching admin products from API: $e');
      return [];
    }
  }

  // VENDOR PRODUCTS MANAGEMENT (from products table)
  static Future<List<ProductModel>> getVendorProducts() async {
    try {
      print('🔍 Fetching vendor products from: ${ApiConstants.vendorProducts}');

      final response = await http.get(
        Uri.parse(ApiConstants.vendorProducts),
        headers: _headers,
      );

      print('🏪 Vendor Products API Response Status: ${response.statusCode}');
      print('🏪 Vendor Products API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);

        List<dynamic> productsData;
        if (responseData['success'] == true) {
          productsData = responseData['products'];
        } else if (responseData is List) {
          productsData = responseData;
        } else if (responseData is Map && responseData.containsKey('products')) {
          productsData = responseData['products'];
        } else {
          print('❌ Unexpected vendor products response format: $responseData');
          return [];
        }

        final vendorProducts = productsData.map((json) {
          print('🔄 Processing vendor product JSON: $json');

          // Handle images for vendor products too
          print('🖼️ Vendor product images field: ${json['images']}');
          print('🖼️ Vendor product image_url field: ${json['image_url']}');

          if (json['images'] == null || (json['images'] is List && json['images'].isEmpty)) {
            if (json['image_url'] != null && json['image_url'].toString().isNotEmpty) {
              json['images'] = [
                'http://10.0.2.2:3005/uploads/${json['image_url']}'
              ];
              print('🖼️ Set vendor images from image_url: ${json['images']}');
            } else {
              json['images'] = [];
              print('🖼️ Set empty vendor images array');
            }
          } else {
            print('🖼️ Using existing vendor images array: ${json['images']}');
          }

          return ProductModel.fromJson(json);
        }).toList();

        print('✅ Successfully parsed ${vendorProducts.length} vendor products from API');
        return vendorProducts;
      } else {
        print('❌ Vendor products API call failed with status: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Error fetching vendor products: $e');
      return [];
    }
  }

  // COMBINED PRODUCTS METHOD (for compatibility)
  static Future<List<ProductModel>> getProducts() async {
    try {
      print('=== FETCHING COMBINED PRODUCTS ===');

      // Fetch both admin and vendor products separately
      final adminProducts = await getAdminProducts();
      final vendorProducts = await getVendorProducts();

      // Combine both lists
      final allProducts = [...adminProducts, ...vendorProducts];

      print('Combined products: ${adminProducts.length} admin + ${vendorProducts.length} vendor = ${allProducts.length} total');
      return allProducts;
    } catch (e) {
      print('Error fetching combined products: $e');
      return [];
    }
  }

  static Future<ProductModel> getProductById(String productId, {bool isAdminProduct = false}) async {
    try {
      print('=== FETCHING SPECIFIC PRODUCT ===');
      print('Product ID: $productId');
      print('Is Admin Product: $isAdminProduct');

      if (isAdminProduct) {
        // Fetch from admin products endpoint
        try {
          final adminResponse = await http.get(
            Uri.parse(ApiConstants.adminProductById(productId)),
            headers: _headers,
          );

          print('Admin product API response status: ${adminResponse.statusCode}');
          print('Admin product API response body: ${adminResponse.body}');

          if (adminResponse.statusCode == 200) {
            final responseData = json.decode(adminResponse.body);

            // Handle both response formats
            final productData = responseData['success'] == true
                ? responseData['product']
                : responseData;

            // Map backend fields to frontend model
            productData['vendorId'] = 'admin';
            productData['vendorName'] = 'Admin Store';
            if (productData['stock_quantity'] != null) {
              productData['stock'] = productData['stock_quantity'];
            }

            // Handle images properly
            if (productData['images'] == null || (productData['images'] is List && productData['images'].isEmpty)) {
              if (productData['image_url'] != null && productData['image_url'].toString().isNotEmpty) {
                productData['images'] = [productData['image_url']];
              } else {
                productData['images'] = [];
              }
            }

            print('Successfully fetched admin product: ${productData['name']}');
            return ProductModel.fromJson(productData);
          } else {
            throw Exception('Admin product not found with status: ${adminResponse.statusCode}');
          }
        } catch (e) {
          print('Error fetching admin product: $e');
          throw Exception('Failed to fetch admin product: $e');
        }
      } else {
        // Fetch from vendor products endpoint
        try {
          final vendorResponse = await http.get(
            Uri.parse(ApiConstants.vendorProductById(productId)),
            headers: _headers,
          );

          print('Vendor product API response status: ${vendorResponse.statusCode}');
          print('Vendor product API response body: ${vendorResponse.body}');

          if (vendorResponse.statusCode == 200) {
            final responseData = json.decode(vendorResponse.body);

            // Handle both response formats
            final productData = responseData['success'] == true
                ? responseData['product']
                : responseData;

            // Handle images for vendor products too
            if (productData['images'] == null || (productData['images'] is List && productData['images'].isEmpty)) {
              if (productData['image_url'] != null && productData['image_url'].toString().isNotEmpty) {
                productData['images'] = [productData['image_url']];
              } else {
                productData['images'] = [];
              }
            }

            print('Successfully fetched vendor product: ${productData['name']}');
            return ProductModel.fromJson(productData);
          } else {
            throw Exception('Vendor product not found with status: ${vendorResponse.statusCode}');
          }
        } catch (e) {
          print('Error fetching vendor product: $e');
          throw Exception('Failed to fetch vendor product: $e');
        }
      }
    } catch (e) {
      print('Error in getProductById: $e');
      throw Exception('Failed to fetch product: $e');
    }
  }

  static Future<List<ProductModel>> getVendorProductsByVendorId(String vendorId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.vendorProducts}?vendorId=$vendorId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);

        List<dynamic> productsData;
        if (responseData['success'] == true) {
          productsData = responseData['products'];
        } else if (responseData is List) {
          productsData = responseData;
        } else if (responseData is Map && responseData.containsKey('products')) {
          productsData = responseData['products'];
        } else {
          return [];
        }

        return productsData.map((json) => ProductModel.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching vendor products: $e');
      return [];
    }
  }

  static Future<bool> addProduct(ProductModel product, {List<File>? imageFiles}) async {
    print('=== ADD PRODUCT API CALL ===');
    print('Product: ${product.name}');
    print('VendorID: "${product.vendorId}"');
    print('VendorName: "${product.vendorName}"');
    print('Image files: ${imageFiles?.length ?? 0}');

    try {
      // Determine which endpoint to use based on vendorId
      String endpoint;
      if (product.vendorId == 'admin' || product.vendorId.isEmpty) {
        endpoint = ApiConstants.adminProducts;
        print('Adding to admin products endpoint: $endpoint');
      } else {
        endpoint = ApiConstants.vendorProducts;
        print('Adding to vendor products endpoint: $endpoint');
      }

      // Create multipart request
      var request = http.MultipartRequest('POST', Uri.parse(endpoint));

      // Don't set Content-Type header manually for multipart requests
      // The http package will set it automatically with the boundary

      // Add text fields - match the backend AdminProduct schema
      request.fields['name'] = product.name;
      request.fields['description'] = product.description;
      request.fields['price'] = product.price.toString();
      request.fields['category'] = product.category;
      request.fields['size'] = product.size ?? '';
      request.fields['stock_quantity'] = product.stock.toString();
      request.fields['stock'] = product.stock.toString(); // Send both for compatibility

      // Set default status
      request.fields['status'] = 'active';

      print('=== FORM FIELDS BEING SENT ===');
      request.fields.forEach((key, value) {
        print('$key: $value');
      });

      // Add image files if any
      if (imageFiles != null && imageFiles.isNotEmpty) {
        print('Adding ${imageFiles.length} image files...');

        for (int i = 0; i < imageFiles.length; i++) {
          final file = imageFiles[i];

          // Check if file exists
          if (!await file.exists()) {
            print('File does not exist: ${file.path}');
            continue;
          }

          final stream = http.ByteStream(file.openRead());
          final length = await file.length();
          final filename = file.path.split('/').last;

          print('Adding file: $filename, size: $length bytes');

          final multipartFile = http.MultipartFile(
            'image', // Use 'image' to match backend expectation for single image
            stream,
            length,
            filename: filename,
            contentType: MediaType('image', _getFileExtension(filename)),
          );

          request.files.add(multipartFile);

          // For admin products, we typically only use the first image
          // since the schema has image_url (single image)
          if (product.vendorId == 'admin' || product.vendorId.isEmpty) {
            break; // Only add first image for admin products
          }
        }
      }

      print('=== SENDING REQUEST ===');
      print('URL: $endpoint');
      print('Method: POST');
      print('Fields: ${request.fields}');
      print('Files: ${request.files.length}');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('=== RESPONSE ===');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('Response Headers: ${response.headers}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('✅ Product successfully added to database');
        return true;
      } else {
        print('❌ Failed to add product. Status: ${response.statusCode}');
        print('Error response: ${response.body}');
        return false;
      }
    } catch (e, stackTrace) {
      print('❌ Error adding product: $e');
      print('Stack trace: $stackTrace');
      return false;
    }
  }

  // Helper method to get file extension
  static String _getFileExtension(String filename) {
    final parts = filename.split('.');
    return parts.length > 1 ? parts.last.toLowerCase() : 'jpg';
  }

  static Future<bool> updateProduct(ProductModel product, {bool isAdminProduct = false, List<File>? imageFiles, List<String>? existingImages}) async {
    try {
      print('=== UPDATING PRODUCT ===');
      print('Product ID: ${product.id}');
      print('Product Name: ${product.name}');
      print('Is Admin Product: $isAdminProduct');
      print('New image files: ${imageFiles?.length ?? 0}');
      print('Existing images: ${existingImages?.length ?? 0}');

      String endpoint;
      if (isAdminProduct || product.vendorId == 'admin') {
        endpoint = ApiConstants.adminProductById(product.id);
        print('Updating admin product at: $endpoint');
      } else {
        endpoint = ApiConstants.vendorProductById(product.id);
        print('Updating vendor product at: $endpoint');
      }

      // Create multipart request for file uploads
      var request = http.MultipartRequest('PUT', Uri.parse(endpoint));

      // Add text fields - match backend schema
      request.fields['name'] = product.name;
      request.fields['description'] = product.description;
      request.fields['price'] = product.price.toString();
      request.fields['category'] = product.category;
      request.fields['size'] = product.size ?? '';
      request.fields['stock'] = product.stock.toString();
      request.fields['stock_quantity'] = product.stock.toString();

      print('=== UPDATE FIELDS BEING SENT ===');
      request.fields.forEach((key, value) {
        print('$key: $value');
      });

      // Add existing images to preserve them
      if (existingImages != null && existingImages.isNotEmpty) {
        print('📸 Preserving ${existingImages.length} existing images');
        for (int i = 0; i < existingImages.length; i++) {
          // Extract filename from full URL if needed
          String imagePath = existingImages[i];
          if (imagePath.contains('/uploads/')) {
            imagePath = imagePath.split('/uploads/').last;
          }
          request.fields['existingImages[$i]'] = imagePath;
          print('   Existing image $i: $imagePath');
        }
      }

      // Add new image files
      if (imageFiles != null && imageFiles.isNotEmpty) {
        print('📸 Adding ${imageFiles.length} new image files');
        for (int i = 0; i < imageFiles.length; i++) {
          final file = imageFiles[i];

          if (!await file.exists()) {
            print('File does not exist: ${file.path}');
            continue;
          }

          final stream = http.ByteStream(file.openRead());
          final length = await file.length();
          final filename = 'image_${DateTime.now().millisecondsSinceEpoch}_$i.${file.path.split('.').last}';

          print('   Adding new image: $filename, size: $length bytes');

          final multipartFile = http.MultipartFile(
            'image',
            stream,
            length,
            filename: filename,
            contentType: MediaType('image', _getFileExtension(filename)),
          );

          request.files.add(multipartFile);
        }
      }

      print('=== SENDING UPDATE REQUEST ===');
      print('URL: $endpoint');
      print('Fields: ${request.fields.length}');
      print('Files: ${request.files.length}');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('=== UPDATE RESPONSE ===');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        print('✅ Product updated successfully');
        return true;
      } else {
        print('❌ Product update failed with status: ${response.statusCode}');
        print('Error response: ${response.body}');
        return false;
      }
    } catch (e, stackTrace) {
      print('❌ Error updating product: $e');
      print('Stack trace: $stackTrace');
      return false;
    }
  }

  static Future<bool> deleteProduct(String productId, {bool isAdminProduct = false}) async {
    try {
      print('=== DELETING PRODUCT ===');
      print('Product ID: $productId');
      print('Is Admin Product: $isAdminProduct');

      String endpoint;
      if (isAdminProduct) {
        endpoint = ApiConstants.adminProductById(productId);
        print('Deleting admin product at: $endpoint');
      } else {
        endpoint = ApiConstants.vendorProductById(productId);
        print('Deleting vendor product at: $endpoint');
      }

      final response = await http.delete(
        Uri.parse(endpoint),
        headers: _headers,
      );

      print('Delete response status: ${response.statusCode}');
      print('Delete response body: ${response.body}');

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('Error deleting product: $e');
      return false;
    }
  }

  // Order Management
  static Future<List<OrderModel>> getOrders() async {
    try {
      print('🔍 Fetching orders from: ${ApiConstants.orders}');

      final response = await http.get(
        Uri.parse(ApiConstants.orders),
        headers: _headers,
      );

      print('📋 Orders response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        // Handle both response formats
        final List<dynamic> ordersData = responseData['success'] == true
            ? responseData['orders']
            : responseData;

        return ordersData.map((json) => OrderModel.fromJson(json)).toList();
      } else {
        print('⚠️ Orders API failed, using mock data');
        return _getMockOrders();
      }
    } catch (e) {
      print('❌ Error fetching orders: $e');
      return _getMockOrders();
    }
  }

  static Future<OrderModel> getOrderById(String orderId) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.orderById(orderId)),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        // Handle both response formats
        final orderData = responseData['success'] == true
            ? responseData['order']
            : responseData;

        return OrderModel.fromJson(orderData);
      } else {
        final orders = _getMockOrders();
        final order = orders.firstWhere(
              (order) => order.id == orderId,
          orElse: () => orders.first,
        );
        return order;
      }
    } catch (e) {
      final orders = _getMockOrders();
      final order = orders.firstWhere(
            (order) => order.id == orderId,
        orElse: () => orders.first,
      );
      return order;
    }
  }

  // Reports Management
  static Future<List<ReportModel>> getReports() async {
    try {
      print('🔍 Fetching reports from: ${ApiConstants.reports}');

      final response = await http.get(
        Uri.parse(ApiConstants.reports),
        headers: _headers,
      );

      print('📊 Reports response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        // Handle both response formats
        final List<dynamic> reportsData = responseData['success'] == true
            ? responseData['reports']
            : responseData;

        return reportsData.map((json) => ReportModel.fromJson(json)).toList();
      } else {
        print('⚠️ Reports API failed, using mock data');
        return _getMockReports();
      }
    } catch (e) {
      print('❌ Error fetching reports: $e');
      return _getMockReports();
    }
  }

  // Mock Data Methods
  static DashboardStats _getMockDashboardStats() {
    return DashboardStats(
      totalUsers: 1250,
      totalVendors: 85,
      totalProducts: 450,
      totalOrders: 320,
      totalRevenue: 45000.0,
      pendingOrders: 25,
      pendingVendors: 8,
      activeReports: 12,
    );
  }

  static List<UserModel> _getMockUsers() {
    return [
      UserModel(
        id: '1',
        name: 'John Doe',
        email: 'john@example.com',
        role: 'user',
        status: 'active',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      UserModel(
        id: '2',
        name: 'Jane Smith',
        email: 'jane@example.com',
        role: 'user',
        status: 'active',
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      UserModel(
        id: '3',
        name: 'Bob Wilson',
        email: 'bob@example.com',
        role: 'user',
        status: 'inactive',
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
      ),
      UserModel(
        id: '4',
        name: 'Alice Johnson',
        email: 'alice@example.com',
        role: 'user',
        status: 'active',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ];
  }

  static List<VendorModel> _getInitialMockVendors() {
    return [
      VendorModel(
        id: '1',
        name: 'Tech Store Inc',
        email: 'tech@store.com',
        phone: '+1234567890',
        address: '123 Tech Street, Silicon Valley, CA',
        status: 'approved',
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
      ),
      VendorModel(
        id: '2',
        name: 'Fashion Hub',
        email: 'fashion@hub.com',
        phone: '+1234567891',
        address: '456 Fashion Ave, New York, NY',
        status: 'pending',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      VendorModel(
        id: '3',
        name: 'Home Goods Co',
        email: 'home@goods.com',
        phone: '+1234567892',
        address: '789 Home Street, Chicago, IL',
        status: 'approved',
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
      ),
      VendorModel(
        id: '4',
        name: 'Beauty World',
        email: 'beauty@world.com',
        phone: '+1234567893',
        address: '321 Beauty Blvd, Los Angeles, CA',
        status: 'blocked',
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
      ),
    ];
  }

  static List<OrderModel> _getMockOrders() {
    return [
      OrderModel(
        id: '1',
        customerId: '1',
        customerName: 'John Doe',
        items: [
          OrderItem(
            productId: '3',
            productName: 'Wireless Headphones',
            quantity: 1,
            price: 199.99,
          ),
        ],
        totalAmount: 219.99,
        status: 'delivered',
        paymentStatus: 'completed',
        shippingAddress: '123 Main St, Anytown, USA',
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
      OrderModel(
        id: '2',
        customerId: '2',
        customerName: 'Jane Smith',
        items: [
          OrderItem(
            productId: '5',
            productName: 'Smart Watch',
            quantity: 1,
            price: 299.99,
          ),
        ],
        totalAmount: 329.99,
        status: 'pending',
        paymentStatus: 'pending',
        shippingAddress: '456 Oak Ave, Another City, USA',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      OrderModel(
        id: '3',
        customerId: '3',
        customerName: 'Bob Wilson',
        items: [
          OrderItem(
            productId: '4',
            productName: 'Perfume',
            quantity: 2,
            price: 170.50,
          ),
        ],
        totalAmount: 371.00,
        status: 'processing',
        paymentStatus: 'completed',
        shippingAddress: '789 Pine St, Third City, USA',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }

  static List<ReportModel> _getMockReports() {
    return [
      ReportModel(
        id: '1',
        userId: '1',
        userName: 'John Doe',
        message: 'Product quality issue with my recent order. The headphones have poor sound quality.',
        status: 'pending',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      ReportModel(
        id: '2',
        userId: '2',
        userName: 'Jane Smith',
        message: 'Shipping delay for order #12345. Expected delivery was yesterday.',
        status: 'resolved',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      ReportModel(
        id: '3',
        userId: '3',
        userName: 'Bob Wilson',
        message: 'Unable to track my order. The tracking number is not working.',
        status: 'pending',
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
      ),
    ];
  }
}
