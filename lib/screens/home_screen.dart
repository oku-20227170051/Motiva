import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/gamification_service.dart';
import '../services/notification_service.dart';
import '../models/user_model.dart';
import '../models/habit_model.dart';
import '../utils/constants.dart';
import 'login_screen.dart';
import 'habit_screen.dart';
import 'calendar_screen.dart';
import 'achievement_screen.dart';
import 'notification_history_screen.dart';
import 'profile_screen.dart';
import 'support_screen.dart';
import 'social_screen.dart';
import 'conversations_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = AuthService();
  final _firestoreService = FirestoreService();
  final _gamificationService = GamificationService();
  final _notificationService = NotificationService();
  
  int _selectedIndex = 0;
  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = _authService.currentUser;
    if (user != null) {
      final userData = await _firestoreService.getUser(user.uid);
      if (mounted) {
        setState(() => _currentUser = userData);
      }
      
      // Günlük bildirimleri arka planda planla (UI'ı bloke etmemek için)
      _notificationService.scheduleDailyNotifications(user.uid).catchError((e) {
        print('Bildirimler planlanamadı: $e');
      });
    }
  }

  Future<void> _handleLogout() async {
    try {
      await _authService.signOut();
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Çıkış yapılamadı: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    
    if (user == null) {
      return const LoginScreen();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text(
          'Motiva',
          style: AppTextStyles.h3.copyWith(color: Colors.white),
        ),
        actions: [
          // Mesajlar butonu - YENİ
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const ConversationsScreen(),
                ),
              );
            },
          ),
          // Destek butonu
          IconButton(
            icon: const Icon(Icons.support_agent, color: Colors.white),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const SupportScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const NotificationHistoryScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textLight,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Ana Sayfa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Sosyal',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle_outline),
            label: 'Alışkanlıklar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Takvim',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events),
            label: 'Başarılar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return const SocialScreen();
      case 2:
        return const HabitScreen();
      case 3:
        return const CalendarScreen();
      case 4:
        return const AchievementScreen();
      case 5:
        return const ProfileScreen();
      default:
        return _buildHomeTab();
    }
  }

  Widget _buildHomeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hoş geldin kartı
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Merhaba, ${_currentUser?.name ?? 'Kullanıcı'}! 👋',
                  style: AppTextStyles.h2.copyWith(color: Colors.white),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                
                // Günün Sözü
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.format_quote,
                            color: Colors.white70,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Günün Sözü',
                            style: AppTextStyles.caption.copyWith(
                              color: Colors.white70,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getDailyQuote(),
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.white,
                          fontStyle: FontStyle.italic,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildStatCard(
                      'Seviye',
                      _gamificationService.calculateLevel(_currentUser?.totalPoints ?? 0).toString(),
                      Icons.star,
                    ),
                    const SizedBox(width: 8),
                    _buildStatCard(
                      'Puan',
                      (_currentUser?.totalPoints ?? 0).toString(),
                      Icons.emoji_events,
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Bugünün alışkanlıkları
          Container(
            margin: const EdgeInsets.all(AppDimensions.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bugünün Alışkanlıkları',
                  style: AppTextStyles.h3,
                ),
                const SizedBox(height: 16),
                StreamBuilder<List<HabitModel>>(
                  stream: _firestoreService.getUserHabits(_authService.currentUser!.uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                          child: Text(
                            'Henüz alışkanlık eklemedin',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      );
                    }

                    // Sadece bugün aktif olan alışkanlıkları filtrele
                    final today = DateTime.now();
                    final todayHabits = snapshot.data!
                        .where((habit) => habit.isActiveOnDate(today))
                        .toList();

                    if (todayHabits.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                          child: Text(
                            'Bugün için aktif alışkanlık yok',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: todayHabits.length,
                      itemBuilder: (context, index) {
                        final habit = todayHabits[index];
                        return _buildHabitCard(habit);
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      value,
                      style: AppTextStyles.h3.copyWith(color: Colors.white),
                      maxLines: 1,
                    ),
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      label,
                      style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHabitCard(HabitModel habit) {
    final isCompleted = habit.isCompletedToday();
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Row(
        children: [
          GestureDetector(
            onTap: () async {
              if (!isCompleted) {
                await _firestoreService.completeHabitToday(habit.id);
                await _gamificationService.awardHabitCompletionPoints(
                  _authService.currentUser!.uid,
                );
                _loadUserData();
              }
            },
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCompleted ? AppColors.success : AppColors.textLight,
                  width: 2,
                ),
                color: isCompleted ? AppColors.success : Colors.transparent,
              ),
              child: isCompleted
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  habit.title,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                if (habit.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    habit.description,
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ],
            ),
          ),
          if (habit.currentStreak > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.local_fire_department, size: 16, color: AppColors.warning),
                  const SizedBox(width: 4),
                  Text(
                    '${habit.currentStreak}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.warning,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 80,
              color: AppColors.textLight,
            ),
            const SizedBox(height: 16),
            Text(
              'Henüz alışkanlık eklemedin',
              style: AppTextStyles.h4.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Text(
              'Alışkanlıklar sekmesinden yeni alışkanlık ekle!',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Günün sözünü getir (rastgele)
  String _getDailyQuote() {
    final quotes = [
      'Hayatta en hakiki mürşit ilimdir, fendir. - Mustafa Kemal Atatürk',
      'Benim naçiz vücudum elbet bir gün toprak olacaktır, ancak Türkiye Cumhuriyeti ilelebet payidar kalacaktır. - Mustafa Kemal Atatürk',
      'Başarı, başarıya inanmakla başlar. - Mustafa Kemal Atatürk',
      'Yurtta sulh, cihanda sulh. - Mustafa Kemal Atatürk',
      'Egemenlik kayıtsız şartsız milletindir. - Mustafa Kemal Atatürk',
      'Muhtaç olduğumuz kudret, damarlarımızdaki asil kanda mevcuttur. - Mustafa Kemal Atatürk',
      'Hayat demek mücadele demektir. - Mustafa Kemal Atatürk',
      'Fikri hür, vicdanı hür, irfanı hür nesiller yetiştiriniz. - Mustafa Kemal Atatürk',
      'Benim için manevi miras, bilim ve akıldır. - Mustafa Kemal Atatürk',
      'Millet, gerçek kurtarıcısının yalnız ve ancak kendisi olduğunu bilmelidir. - Mustafa Kemal Atatürk',
      'Dünyada her şey için, medeniyet için, hayat için, muvaffakiyet için en hakiki mürşit ilimdir, fendir. - Mustafa Kemal Atatürk',
      'Bir milletin varlığı, ancak kendi benliğini muhafaza etmesiyle mümkündür. - Mustafa Kemal Atatürk',
      'Türk gençliği! Birinci vazifen, Türk istiklalini, Türk Cumhuriyetini, ilelebet muhafaza ve müdafaa etmektir. - Mustafa Kemal Atatürk',
      'Hakkı olan milletlerin hakkını vermemek, onların ellerinden zorla almak demektir. - Mustafa Kemal Atatürk',
      'Zafer, zafer benimdir diyebilenindir. Başarı ise, başaracağım diye başlayarak sonuna kadar azimle yürüyenindir. - Mustafa Kemal Atatürk',
      'Hayatta muvaffak olmak için sebat ve azim şarttır. - Mustafa Kemal Atatürk',
      'Biz Türkler, tarih boyunca hürriyet ve istiklale timsal olmuş bir milletiz. - Mustafa Kemal Atatürk',
      'Şunu iyi biliniz ki, Türk istiklali ve cumhuriyeti, ancak Türk gençliğinin azim ve kararı ile korunabilir. - Mustafa Kemal Atatürk',
      'Gücünü milletten alan ordu yenilmez. - Mustafa Kemal Atatürk',
      'Milletimizin karakterinde tembellik yoktur. Türk milleti çalışkandır. - Mustafa Kemal Atatürk',
    ];
    
    // Rastgele söz seç (her açılışta farklı)
    final random = DateTime.now().millisecondsSinceEpoch % quotes.length;
    
    return quotes[random];
  }
}
