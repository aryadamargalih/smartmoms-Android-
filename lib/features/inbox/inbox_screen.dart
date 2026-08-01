import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  // Dummy data pesan dari admin/dokter
  final List<_InboxMessage> _messages = [
    _InboxMessage(
      id: '1',
      senderName: 'dr. Rina Susanti, Sp.OG',
      senderRole: 'Dokter Kandungan',
      subject: 'Hasil Pemeriksaan Minggu ke-24',
      message:
          'Selamat siang Bunda Siti! Berdasarkan data kesehatan minggu ini, kondisi Bunda secara umum baik. BPM dan tekanan darah dalam batas normal. Tetap jaga pola makan dan istirahat yang cukup ya. Jangan lupa kontrol minggu depan!',
      time: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: false,
      type: 'doctor',
    ),
    _InboxMessage(
      id: '2',
      senderName: 'Admin SmartMoms',
      senderRole: 'Administrator',
      subject: 'Pengingat Kuesioner EPDS',
      message:
          'Halo Bunda! Sudah waktunya mengisi kuesioner EPDS mingguan. Kuesioner ini membantu tim medis memantau kondisi kesehatan mental Bunda selama kehamilan. Silakan buka menu Kuesioner untuk mengisi sekarang.',
      time: DateTime.now().subtract(const Duration(days: 1)),
      isRead: false,
      type: 'admin',
    ),
    _InboxMessage(
      id: '3',
      senderName: 'dr. Rina Susanti, Sp.OG',
      senderRole: 'Dokter Kandungan',
      subject: 'Tips Aktivitas Fisik Trimester 2',
      message:
          'Bunda, di trimester 2 ini sangat disarankan untuk tetap aktif bergerak. Jalan kaki 30 menit setiap pagi sangat baik untuk sirkulasi darah dan mempersiapkan tubuh menjelang persalinan. Hindari olahraga berat dan pastikan selalu terhidrasi!',
      time: DateTime.now().subtract(const Duration(days: 3)),
      isRead: true,
      type: 'doctor',
    ),
    _InboxMessage(
      id: '4',
      senderName: 'Admin SmartMoms',
      senderRole: 'Administrator',
      subject: 'Selamat Datang di SmartMoms!',
      message:
          'Halo Bunda Siti! Selamat bergabung di SmartMoms. Aplikasi ini akan membantu memantau kesehatan Bunda dan bayi selama kehamilan. Hubungkan smartwatch Bunda untuk mulai memantau BPM dan tekanan darah secara real-time. Semoga kehamilan Bunda sehat dan lancar!',
      time: DateTime.now().subtract(const Duration(days: 7)),
      isRead: true,
      type: 'admin',
    ),
  ];

  int get _unreadCount => _messages.where((m) => !m.isRead).length;

  void _markAsRead(String id) {
    setState(() {
      final msg = _messages.firstWhere((m) => m.id == id);
      msg.isRead = true;
    });
  }

  void _markAllAsRead() {
    setState(() {
      for (final msg in _messages) {
        msg.isRead = true;
      }
    });
  }

  void _openMessage(_InboxMessage message) {
    _markAsRead(message.id);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _MessageDetail(message: message),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Pesan Masuk',
                style: TextStyle(fontWeight: FontWeight.w700)),
            if (_unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.danger,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$_unreadCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text(
                'Tandai semua',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
      body: _messages.isEmpty
          ? _EmptyInbox(isDark: isDark)
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _MessageCard(
                message: _messages[i],
                isDark: isDark,
                onTap: () => _openMessage(_messages[i]),
              ),
            ),
    );
  }
}

// ─── Message Card ──────────────────────────────────────────────────────────
class _MessageCard extends StatelessWidget {
  final _InboxMessage message;
  final bool isDark;
  final VoidCallback onTap;

  const _MessageCard({
    required this.message,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDoctor = message.type == 'doctor';

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: message.isRead
              ? (isDark ? AppColors.darkCard : AppColors.lightCard)
              : (isDark
                  ? AppColors.primary.withOpacity(0.08)
                  : AppColors.primary.withOpacity(0.04)),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: message.isRead
                ? (isDark ? AppColors.darkDivider : AppColors.lightDivider)
                : AppColors.primary.withOpacity(0.3),
            width: message.isRead ? 1 : 1.5,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: isDoctor
                    ? AppColors.primary.withOpacity(0.12)
                    : AppColors.accent.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                isDoctor
                    ? Icons.medical_services_rounded
                    : Icons.admin_panel_settings_rounded,
                color: isDoctor ? AppColors.primary : AppColors.accent,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          message.senderName,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.darkText
                                : AppColors.lightText,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        _formatTime(message.time),
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isDoctor
                              ? AppColors.primary.withOpacity(0.1)
                              : AppColors.accent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          message.senderRole,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color:
                                isDoctor ? AppColors.primary : AppColors.accent,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    message.subject,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          message.isRead ? FontWeight.w500 : FontWeight.w700,
                      color: isDark ? AppColors.darkText : AppColors.lightText,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    message.message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            // Unread dot
            if (!message.isRead) ...[
              const SizedBox(width: 8),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}j ago';
    if (diff.inDays < 7) return '${diff.inDays}h ago';
    return '${time.day}/${time.month}/${time.year}';
  }
}

// ─── Message Detail Bottom Sheet ───────────────────────────────────────────
class _MessageDetail extends StatelessWidget {
  final _InboxMessage message;

  const _MessageDetail({required this.message});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDoctor = message.type == 'doctor';

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
          24, 16, 24, MediaQuery.of(context).viewInsets.bottom + 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Sender info
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isDoctor
                      ? AppColors.primary.withOpacity(0.12)
                      : AppColors.accent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  isDoctor
                      ? Icons.medical_services_rounded
                      : Icons.admin_panel_settings_rounded,
                  color: isDoctor ? AppColors.primary : AppColors.accent,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.senderName,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color:
                            isDark ? AppColors.darkText : AppColors.lightText,
                      ),
                    ),
                    Text(
                      message.senderRole,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDoctor ? AppColors.primary : AppColors.accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${message.time.day}/${message.time.month}/${message.time.year}',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Divider(
            color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
          ),
          const SizedBox(height: 12),

          // Subject
          Text(
            message.subject,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.darkText : AppColors.lightText,
            ),
          ),
          const SizedBox(height: 12),

          // Message body
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightBackground,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              message.message,
              style: TextStyle(
                fontSize: 14,
                height: 1.7,
                color: isDark ? AppColors.darkText : AppColors.lightText,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Tutup button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(
                  color:
                      isDark ? AppColors.darkDivider : AppColors.lightDivider,
                ),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                'Tutup',
                style: TextStyle(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Empty State ───────────────────────────────────────────────────────────
class _EmptyInbox extends StatelessWidget {
  final bool isDark;
  const _EmptyInbox({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.mark_email_read_outlined,
              size: 52,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Tidak ada pesan',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            'Pesan dari dokter atau admin\nakan muncul di sini',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Model ─────────────────────────────────────────────────────────────────
class _InboxMessage {
  final String id;
  final String senderName;
  final String senderRole;
  final String subject;
  final String message;
  final DateTime time;
  bool isRead;
  final String type; // 'doctor' atau 'admin'

  _InboxMessage({
    required this.id,
    required this.senderName,
    required this.senderRole,
    required this.subject,
    required this.message,
    required this.time,
    required this.isRead,
    required this.type,
  });
}
