class VendorModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String status;
  final DateTime createdAt;

  VendorModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.status,
    required this.createdAt,
  });

  factory VendorModel.fromJson(Map<String, dynamic> json) {
    return VendorModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      status: json['status'] ?? 'pending',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
