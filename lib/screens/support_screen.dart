import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/support_ticket_model.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final _authService = AuthService();
  final _firestoreService = FirestoreService();
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  
  String _selectedType = 'support';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitTicket() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final user = _authService.currentUser;
      if (user == null) throw 'Kullanıcı bulunamadı';

      final userData = await _firestoreService.getUser(user.uid);
      if (userData == null) throw 'Kullanıcı bilgileri alınamadı';

      final ticket = SupportTicketModel(
        id: '',
        userId: user.uid,
        userName: userData.name,
        userEmail: userData.email,
        type: _selectedType,
        subject: _subjectController.text.trim(),
        message: _messageController.text.trim(),
      );

      await _firestoreService.createSupportTicket(ticket);

      if (mounted) {
        _subjectController.clear();
        _messageController.clear();
        setState(() => _selectedType = 'support');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Talebiniz başarıyla gönderildi!'),
            backgroundColor: AppColors.success,
          ),
        );
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
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Destek ve Talep'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Yeni Talep Formu
            Container(
              margin: const EdgeInsets.all(AppDimensions.paddingMedium),
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Yeni Talep Oluştur',
                      style: AppTextStyles.h3,
                    ),
                    const SizedBox(height: 16),

                    // Talep Türü
                    Text(
                      'Talep Türü',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedType,
                          isExpanded: true,
                          items: const [
                            DropdownMenuItem(
                              value: 'password_reset',
                              child: Row(
                                children: [
                                  Icon(Icons.lock_reset, size: 20),
                                  SizedBox(width: 8),
                                  Text('Şifre Sıfırlama'),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'support',
                              child: Row(
                                children: [
                                  Icon(Icons.support_agent, size: 20),
                                  SizedBox(width: 8),
                                  Text('Genel Destek'),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'suggestion',
                              child: Row(
                                children: [
                                  Icon(Icons.lightbulb_outline, size: 20),
                                  SizedBox(width: 8),
                                  Text('Öneri'),
                                ],
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _selectedType = value);
                            }
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Konu
                    CustomTextField(
                      controller: _subjectController,
                      label: 'Konu',
                      hint: 'Talebinizin konusunu yazın',
                      validator: (value) => Validators.validateRequired(value, 'Konu'),
                      prefixIcon: const Icon(Icons.subject),
                    ),

                    const SizedBox(height: 16),

                    // Mesaj
                    CustomTextField(
                      controller: _messageController,
                      label: 'Mesaj',
                      hint: 'Detaylı açıklama yazın',
                      maxLines: 5,
                      validator: (value) => Validators.validateRequired(value, 'Mesaj'),
                      prefixIcon: const Icon(Icons.message),
                    ),

                    const SizedBox(height: 24),

                    // Gönder Butonu
                    CustomButton(
                      text: 'Talep Gönder',
                      onPressed: _submitTicket,
                      isLoading: _isSubmitting,
                      icon: Icons.send,
                    ),
                  ],
                ),
              ),
            ),

            // Taleplerim
            Container(
              margin: const EdgeInsets.all(AppDimensions.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Taleplerim',
                    style: AppTextStyles.h3,
                  ),
                  const SizedBox(height: 16),

                  StreamBuilder<List<SupportTicketModel>>(
                    stream: _firestoreService.getUserTickets(_authService.currentUser!.uid),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      // HATA KONTROLÜ - EKRANDA GÖSTER
                      if (snapshot.hasError) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 64,
                                  color: AppColors.error,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'HATA!',
                                  style: AppTextStyles.h3.copyWith(
                                    color: AppColors.error,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${snapshot.error}',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.error,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.inbox_outlined,
                                  size: 64,
                                  color: AppColors.textLight,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Henüz talep oluşturmadınız',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      final tickets = snapshot.data!;
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: tickets.length,
                        itemBuilder: (context, index) {
                          final ticket = tickets[index];
                          return _buildTicketCard(ticket);
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketCard(SupportTicketModel ticket) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm', 'tr_TR');
    
    Color statusColor;
    IconData statusIcon;
    
    switch (ticket.status) {
      case 'pending':
        statusColor = AppColors.warning;
        statusIcon = Icons.pending;
        break;
      case 'in_progress':
        statusColor = AppColors.info;
        statusIcon = Icons.hourglass_empty;
        break;
      case 'resolved':
        statusColor = AppColors.success;
        statusIcon = Icons.check_circle;
        break;
      case 'rejected':
        statusColor = AppColors.error;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = AppColors.textLight;
        statusIcon = Icons.help_outline;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
        border: Border.all(color: statusColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        leading: Icon(statusIcon, color: statusColor),
        title: Text(
          ticket.subject,
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    ticket.statusDisplay,
                    style: AppTextStyles.caption.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  ticket.typeDisplay,
                  style: AppTextStyles.caption,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              dateFormat.format(ticket.createdAt),
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textLight,
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mesajınız:',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  ticket.message,
                  style: AppTextStyles.bodyMedium,
                ),
                
                if (ticket.adminResponse != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.info.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
                      border: Border.all(color: AppColors.info.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.admin_panel_settings, size: 16, color: AppColors.info),
                            const SizedBox(width: 4),
                            Text(
                              'Admin Yanıtı:',
                              style: AppTextStyles.bodySmall.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.info,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          ticket.adminResponse!,
                          style: AppTextStyles.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
