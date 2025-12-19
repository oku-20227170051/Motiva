import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../models/support_ticket_model.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_button.dart';

class AdminTicketDetailScreen extends StatefulWidget {
  final SupportTicketModel ticket;

  const AdminTicketDetailScreen({
    super.key,
    required this.ticket,
  });

  @override
  State<AdminTicketDetailScreen> createState() => _AdminTicketDetailScreenState();
}

class _AdminTicketDetailScreenState extends State<AdminTicketDetailScreen> {
  final _authService = AuthService();
  final _firestoreService = FirestoreService();
  final _responseController = TextEditingController();
  
  String _selectedStatus = '';
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.ticket.status;
    if (widget.ticket.adminResponse != null) {
      _responseController.text = widget.ticket.adminResponse!;
    }
  }

  @override
  void dispose() {
    _responseController.dispose();
    super.dispose();
  }

  Future<void> _updateTicket() async {
    setState(() => _isUpdating = true);

    try {
      await _firestoreService.updateTicketStatus(
        widget.ticket.id,
        _selectedStatus,
        adminResponse: _responseController.text.trim().isEmpty
            ? null
            : _responseController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Talep güncellendi'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
  }

  Future<void> _sendPasswordResetEmail() async {
    try {
      await _authService.sendPasswordResetEmail(widget.ticket.userEmail);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Şifre sıfırlama e-postası gönderildi'),
            backgroundColor: AppColors.success,
          ),
        );
        
        // Otomatik olarak durumu güncelle
        setState(() => _selectedStatus = 'resolved');
        _responseController.text = 'Şifre sıfırlama e-postası gönderildi. Lütfen e-postanızı kontrol edin.';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm', 'tr_TR');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Talep Detayı'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kullanıcı Bilgileri
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kullanıcı Bilgileri',
                    style: AppTextStyles.h4,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(Icons.person, 'Ad', widget.ticket.userName),
                  const SizedBox(height: 8),
                  _buildInfoRow(Icons.email, 'E-posta', widget.ticket.userEmail),
                  const SizedBox(height: 8),
                  _buildInfoRow(Icons.calendar_today, 'Tarih', dateFormat.format(widget.ticket.createdAt)),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Talep Detayları
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Talep Detayları',
                    style: AppTextStyles.h4,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(Icons.category, 'Tür', widget.ticket.typeDisplay),
                  const SizedBox(height: 8),
                  _buildInfoRow(Icons.subject, 'Konu', widget.ticket.subject),
                  const SizedBox(height: 12),
                  Text(
                    'Mesaj:',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.ticket.message,
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Şifre Sıfırlama Butonu (sadece password_reset için)
            if (widget.ticket.type == 'password_reset')
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
                  border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Icon(Icons.lock_reset, color: AppColors.warning, size: 32),
                    const SizedBox(height: 8),
                    Text(
                      'Şifre Sıfırlama Talebi',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Kullanıcıya şifre sıfırlama e-postası göndermek için butona tıklayın.',
                      style: AppTextStyles.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _sendPasswordResetEmail,
                      icon: const Icon(Icons.email),
                      label: const Text('Şifre Sıfırlama E-postası Gönder'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.warning,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 16),

            // Durum Güncelleme
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Durum Güncelle',
                    style: AppTextStyles.h4,
                  ),
                  const SizedBox(height: 12),
                  
                  // Durum Seçimi
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedStatus,
                        isExpanded: true,
                        items: const [
                          DropdownMenuItem(
                            value: 'pending',
                            child: Text('Beklemede'),
                          ),
                          DropdownMenuItem(
                            value: 'in_progress',
                            child: Text('İşlemde'),
                          ),
                          DropdownMenuItem(
                            value: 'resolved',
                            child: Text('Çözüldü'),
                          ),
                          DropdownMenuItem(
                            value: 'rejected',
                            child: Text('Reddedildi'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedStatus = value);
                          }
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Admin Yanıtı
                  Text(
                    'Admin Yanıtı (Opsiyonel):',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _responseController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Kullanıcıya yanıt yazın...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Güncelle Butonu
                  CustomButton(
                    text: 'Güncelle',
                    onPressed: _updateTicket,
                    isLoading: _isUpdating,
                    icon: Icons.save,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.bodyMedium,
          ),
        ),
      ],
    );
  }
}
