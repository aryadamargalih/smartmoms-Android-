import 'package:flutter/material.dart';
import '../services/api_service.dart';

class InboxMessage {
  final int id;
  final String senderName;
  final String senderRole;
  final String subject;
  final String message;
  final String sentAt;
  bool isRead;
  final String type;

  InboxMessage({
    required this.id,
    required this.senderName,
    required this.senderRole,
    required this.subject,
    required this.message,
    required this.sentAt,
    required this.isRead,
    required this.type,
  });

  factory InboxMessage.fromJson(Map<String, dynamic> json) {
    return InboxMessage(
      id: json['id'],
      senderName: json['admin']?['name'] ?? 'Admin SmartMoms',
      senderRole:
          json['admin']?['role'] == 'doctor' ? 'Dokter' : 'Administrator',
      subject: json['subject'] ?? '',
      message: json['message'] ?? '',
      sentAt: json['sent_at'] ?? '',
      isRead: json['is_read'] ?? false,
      type: json['admin']?['role'] ?? 'admin',
    );
  }
}

class InboxProvider extends ChangeNotifier {
  List<InboxMessage> _messages = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<InboxMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get unreadCount => _messages.where((m) => !m.isRead).length;

  // ── Fetch messages ──────────────────────────────────────────────────
  Future<void> fetchMessages() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await ApiService.get('/messages');

    _isLoading = false;

    if (response['success'] == true) {
      _messages = (response['data'] as List)
          .map((m) => InboxMessage.fromJson(m))
          .toList();
    } else {
      _errorMessage = response['message'];
    }
    notifyListeners();
  }

  // ── Mark as read ────────────────────────────────────────────────────
  Future<void> markAsRead(int id) async {
    final response = await ApiService.put('/messages/$id/read');

    if (response['success'] == true) {
      final index = _messages.indexWhere((m) => m.id == id);
      if (index != -1) {
        _messages[index].isRead = true;
        notifyListeners();
      }
    }
  }

  // ── Mark all as read ────────────────────────────────────────────────
  Future<void> markAllAsRead() async {
    final unread = _messages.where((m) => !m.isRead).toList();
    for (final msg in unread) {
      await markAsRead(msg.id);
    }
  }
}
