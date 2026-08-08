import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ProfileProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;

  // ── Update profile ──────────────────────────────────────────────────
  Future<bool> updateProfile({
    required String name,
    required String email,
    required String phone,
    required int age,
    required String bloodType,
    required double weight,
    required double height,
    required String deliveryDate,
  }) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    final response = await ApiService.put('/user/profile', body: {
      'name': name,
      'email': email,
      'phone': phone,
      'age': age,
      'blood_type': bloodType,
      'weight': weight,
      'height': height,
      'delivery_date': deliveryDate,
    });

    _isSaving = false;

    if (response['success'] == true) {
      notifyListeners();
      return true;
    } else {
      _errorMessage = response['message'];
      notifyListeners();
      return false;
    }
  }

  // ── Update nifas info ───────────────────────────────────────────────
  Future<bool> updateNifasInfo({
    required String doctorName,
    required String hospitalName,
    required String deliveryDate,
  }) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    final response = await ApiService.put('/user/nifas-info', body: {
      'doctor_name': doctorName,
      'hospital_name': hospitalName,
      'delivery_date': deliveryDate,
    });

    _isSaving = false;

    if (response['success'] == true) {
      notifyListeners();
      return true;
    } else {
      _errorMessage = response['message'];
      notifyListeners();
      return false;
    }
  }
}
