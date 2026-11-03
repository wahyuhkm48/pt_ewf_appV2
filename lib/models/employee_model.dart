// models/employee_model.dart
class EmployeeModel {
  final String userId;
  final String namaLengkap;
  final String email;
  final String? foto;
  final String? noTelp;
  final DateTime? createdAt;

  EmployeeModel({
    required this.userId,
    required this.namaLengkap,
    required this.email,
    this.foto,
    this.noTelp,
    this.createdAt,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) => EmployeeModel(
        userId: json['user_id'],
        namaLengkap: json['nama_lengkap'],
        email: json['email'],
        foto: json['foto'],
        noTelp: json['no_telp'],
        createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      );

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'nama_lengkap': namaLengkap,
        'email': email,
        'foto': foto,
        'no_telp': noTelp,
        'created_at': createdAt?.toIso8601String(),
      };
}