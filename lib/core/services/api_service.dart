import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  // Untuk emulator Android gunakan 10.0.2.2
  static const String baseUrl = 'http://10.0.2.2:8000/api';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  // ── Get token dari storage ──────────────────────────────────────────
  static Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  // ── Save token ke storage ───────────────────────────────────────────
  static Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  // ── Delete token ────────────────────────────────────────────────────
  static Future<void> deleteToken() async {
    await _storage.delete(key: 'auth_token');
  }

  // ── Default headers ─────────────────────────────────────────────────
  static Future<Map<String, String>> _headers({bool auth = true}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (auth) {
      final token = await getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  // ── GET ─────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl$endpoint'),
            headers: await _headers(),
          )
          .timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Koneksi gagal: $e'};
    }
  }

  // ── POST ────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    bool auth = true,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl$endpoint'),
            headers: await _headers(auth: auth),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Koneksi gagal: $e'};
    }
  }

  // ── PUT ─────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl$endpoint'),
            headers: await _headers(),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Koneksi gagal: $e'};
    }
  }

  // ── DELETE ──────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final response = await http
          .delete(
            Uri.parse('$baseUrl$endpoint'),
            headers: await _headers(),
          )
          .timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Koneksi gagal: $e'};
    }
  }

  // ── Handle Response ─────────────────────────────────────────────────
  static Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final data = jsonDecode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data;
      } else if (response.statusCode == 401) {
        return {'success': false, 'message': 'Sesi habis, silakan login ulang'};
      } else if (response.statusCode == 422) {
        return {
          'success': false,
          'message': data['message'] ?? 'Validasi gagal',
          'errors': data['errors']
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Terjadi kesalahan'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Format response tidak valid'};
    }
  }
}
