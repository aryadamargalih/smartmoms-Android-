import 'package:flutter/material.dart';
import '../services/api_service.dart';

class UserModel {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final int? age;
  final String? bloodType;
  final double? weight;
  final double? height;
  final String? deliveryDate;
  final int? nifasDay;
  final String? doctorName;
  final String? hospitalName;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.age,
    this.bloodType,
    this.weight,
    this.height,
    this.deliveryDate,
    this.nifasDay,
    this.doctorName,
    this.hospitalName,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      age: json['age'],
      bloodType: json['blood_type'],
      weight: json['weight'] != null
          ? double.tryParse(json['weight'].toString())
          : null,
      height: json['height'] != null
          ? double.tryParse(json['height'].toString())
          : null,
      deliveryDate: json['delivery_date'],
      nifasDay: json['nifas_day'],
      doctorName: json['doctor_name'],
      hospitalName: json['hospital_name'],
    );
  }
}

class AuthProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _user != null;

  // ── Login ───────────────────────────────────────────────────────────
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await ApiService.post(
      '/auth/login',
      body: {'email': email, 'password': password},
      auth: false,
    );

    _isLoading = false;

    if (response['success'] == true) {
      await ApiService.saveToken(response['data']['token']);
      _user = UserModel.fromJson(response['data']['user']);
      notifyListeners();
      return true;
    } else {
      _errorMessage = response['message'];
      notifyListeners();
      return false;
    }
  }

  // ── Register ────────────────────────────────────────────────────────
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String deliveryDate,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await ApiService.post(
      '/auth/register',
      body: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': password,
        'phone': phone,
        'delivery_date': deliveryDate,
      },
      auth: false,
    );

    _isLoading = false;

    if (response['success'] == true) {
      await ApiService.saveToken(response['data']['token']);
      _user = UserModel.fromJson(response['data']['user']);
      notifyListeners();
      return true;
    } else {
      _errorMessage = response['message'];
      notifyListeners();
      return false;
    }
  }

  // ── Logout ──────────────────────────────────────────────────────────
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    await ApiService.post('/auth/logout');
    await ApiService.deleteToken();
    _user = null;
    _isLoading = false;
    notifyListeners();
  }

  // ── Get current user ────────────────────────────────────────────────
  Future<void> fetchMe() async {
    final token = await ApiService.getToken();
    if (token == null) return;

    final response = await ApiService.get('/auth/me');
    if (response['success'] == true) {
      _user = UserModel.fromJson(response['data']);
      notifyListeners();
    }
  }

  // ── Clear error ─────────────────────────────────────────────────────
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
