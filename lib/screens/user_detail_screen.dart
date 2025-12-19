import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../models/achievement_model.dart';
import '../services/firestore_service.dart';
import '../utils/constants.dart';
import 'chat_screen.dart';

class UserDetailScreen extends StatefulWidget {
  final UserModel user;

  const UserDetailScreen({
    super.key,
    required this.user,
  });

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  final _firestoreService = FirestoreService();
  int _habitCount = 0;
  List<AchievementModel> _achievements = [];
  bool _isLoading = true;
  bool _isFriend = false;
  bool _hasPendingRequest = false; // YENİ
  bool _isProcessing = false;
  
  String? get _currentUserId => FirebaseAuth.instance.currentUser?.uid;
  bool get _isOwnProfile => _currentUserId == widget.user.uid;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final habitCount = await _firestoreService.getUserHabitCount(widget.user.uid);
    final achievements = await _firestoreService.getUserAchievements(widget.user.uid);
    
    bool isFriend = false;
    bool hasPendingRequest = false;
    
    if (!_isOwnProfile && _currentUserId != null) {
      isFriend = await _firestoreService.isFriend(_currentUserId!, widget.user.uid);
      if (!isFriend) {
        hasPendingRequest = await _firestoreService.hasPendingRequest(_currentUserId!, widget.user.uid);
      }
    }
    
    setState(() {
      _habitCount = habitCount;
      _achievements = achievements;
      _isFriend = isFriend;
      _hasPendingRequest = hasPendingRequest;
      _isLoading = false;
    });
  }

  Future<void> _sendFriendRequest() async {
    if (_currentUserId == null || _isOwnProfile) return;
    
    setState(() => _isProcessing = true);

    try {
      await _firestoreService.sendFriendRequest(_currentUserId!, widget.user.uid);
      setState(() {
        _hasPendingRequest = true;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Arkadaşlık isteği gönderildi!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _removeFriend() async {
    if (_currentUserId == null || _isOwnProfile) return;
    
    setState(() => _isProcessing = true);

    try {
      await _firestoreService.removeFriend(_currentUserId!, widget.user.uid);
      setState(() => _isFriend = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Arkadaşlıktan çıkarıldı')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _openChat() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatScreen(otherUser: widget.user),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('@${widget.user.username}'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Profil Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white,
                          child: Text(
                            widget.user.name[0].toUpperCase(),
                            style: AppTextStyles.h1.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.user.name,
                          style: AppTextStyles.h2.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '@${widget.user.username}',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // İstatistikler
                  Padding(
                    padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'İstatistikler',
                          style: AppTextStyles.h3,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                'Seviye',
                                widget.user.level.toString(),
                                Icons.star,
                                AppColors.warning,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                'Puan',
                                widget.user.totalPoints.toString(),
                                Icons.emoji_events,
                                AppColors.success,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                'Alışkanlık',
                                _habitCount.toString(),
                                Icons.check_circle,
                                AppColors.info,
                              ),
                            ),
                          ],
                        ),
                        
                        // Arkadaşlık Butonları
                        if (!_isOwnProfile) ...[
                          const SizedBox(height: 24),
                          
                          // Arkadaşsa: Mesaj Gönder + Arkadaşlıktan Çıkar
                          if (_isFriend) ...[
                            Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: ElevatedButton.icon(
                                    onPressed: _openChat,
                                    icon: const Icon(Icons.message),
                                    label: const Text('Mesaj Gönder'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _isProcessing ? null : _removeFriend,
                                    icon: const Icon(Icons.person_remove, size: 20),
                                    label: const Text('Çıkar'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.error,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ]
                          // İstek gönderilmişse: İstek Gönderildi (disabled)
                          else if (_hasPendingRequest) ...[
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: null,
                                icon: const Icon(Icons.schedule),
                                label: const Text('İstek Gönderildi'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
                                  ),
                                ),
                              ),
                            ),
                          ]
                          // Arkadaş değilse: İstek Gönder
                          else ...[
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _isProcessing ? null : _sendFriendRequest,
                                icon: const Icon(Icons.person_add),
                                label: const Text('Arkadaşlık İsteği Gönder'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                        
                        // Başarımlar
                        const SizedBox(height: 32),
                        Text(
                          'Başarımlar',
                          style: AppTextStyles.h3,
                        ),
                        const SizedBox(height: 16),
                        _achievements.isEmpty
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(32.0),
                                  child: Text(
                                    'Henüz başarım yok',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.textLight,
                                    ),
                                  ),
                                ),
                              )
                            : GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: 0.8,
                                ),
                                itemCount: _achievements.length,
                                itemBuilder: (context, index) {
                                  return _buildAchievementCard(_achievements[index]);
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

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
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
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.h2.copyWith(
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(AchievementModel achievement) {
    // Icon name'den icon oluştur
    IconData iconData = Icons.emoji_events; // Varsayılan icon
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: achievement.isUnlocked ? Colors.white : Colors.grey[200],
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
        border: Border.all(
          color: achievement.isUnlocked ? AppColors.primary.withOpacity(0.3) : Colors.grey[300]!,
        ),
        boxShadow: achievement.isUnlocked
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            iconData,
            size: 32,
            color: achievement.isUnlocked ? AppColors.primary : Colors.grey,
          ),
          const SizedBox(height: 8),
          Text(
            achievement.title,
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.bold,
              color: achievement.isUnlocked ? AppColors.textPrimary : Colors.grey,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
