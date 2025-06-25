class ReportModel {
  final String id;
  final String userId;
  final String userName;
  final String message;
  final String status;
  final DateTime createdAt;

  ReportModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.message,
    required this.status,
    required this.createdAt,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      message: json['message'] ?? '',
      status: json['status'] ?? 'pending',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'userName': userName,
      'message': message,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
