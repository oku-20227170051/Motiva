import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/gamification_service.dart';
import '../models/user_model.dart';
import '../models/achievement_model.dart';
import '../models/progress_model.dart';
import '../utils/constants.dart';

class AchievementScreen extends StatefulWidget {
  const AchievementScreen({super.key});

  @override
  State<AchievementScreen> createState() => _AchievementScreenState();
}

class _AchievementScreenState extends State<AchievementScreen> {
  final _authService = AuthService();
  final _firestoreService = FirestoreService();
  final _gamificationService = GamificationService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Kullanıcı İstatistikleri
            FutureBuilder<UserModel?>(
              future: _firestoreService.getUser(_authService.currentUser!.uid),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox.shrink();
                }

                final user = snapshot.data!;
                final level = _gamificationService.calculateLevel(user.totalPoints);
                final levelProgress = _gamificationService.levelProgress(user.totalPoints);

                return Container(
                  margin: const EdgeInsets.all(AppDimensions.paddingMedium),
                  padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
                  ),
                  child: Column(
                    children: [
                      // Avatar ve Seviye
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white,
                        child: FittedBox(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              level.toString(),
                              style: AppTextStyles.h1.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        user.name,
                        style: AppTextStyles.h2.copyWith(color: Colors.white),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Seviye $level',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Seviye İlerleme Çubuğu
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  'Seviye İlerlemesi',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: Colors.white,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                '${levelProgress.toInt()}%',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: levelProgress / 100,
                              minHeight: 8,
                              backgroundColor: Colors.white.withOpacity(0.3),
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Puan Kartları
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              'Toplam Puan',
                              user.totalPoints.toString(),
                              Icons.stars,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildStatCard(
                              'Sonraki Seviye',
                              '${_gamificationService.pointsForNextLevel(level)}p',
                              Icons.trending_up,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),

            // Başarılar
            Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Başarılar',
                    style: AppTextStyles.h3,
                  ),
                  const SizedBox(height: 16),
                  
                  FutureBuilder<List<AchievementModel>>(
                    future: _firestoreService.getUserAchievements(
                      _authService.currentUser!.uid,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final userAchievements = snapshot.data ?? [];
                      final allAchievements = AchievementModel.getDefaultAchievements();

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.85,
                        ),
                        itemCount: allAchievements.length,
                        itemBuilder: (context, index) {
                          final achievement = allAchievements[index];
                          final isUnlocked = userAchievements.any(
                            (a) => a.id == achievement.id && a.isUnlocked,
                          );
                          
                          return _buildAchievementCard(achievement, isUnlocked);
                        },
                      );
                    },
                  ),
                ],
              ),
            ),

            // İlerleme Grafikleri
            Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Son 7 Günlük İlerleme',
                    style: AppTextStyles.h3,
                  ),
                  const SizedBox(height: 16),
                  
                  StreamBuilder<List<ProgressModel>>(
                    stream: _firestoreService.getUserProgress(
                      _authService.currentUser!.uid,
                      days: 7,
                    ),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
                          ),
                          child: Center(
                            child: Text(
                              'Henüz ilerleme verisi yok',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        );
                      }

                      final progressData = snapshot.data!;
                      
                      return Container(
                        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
                        ),
                        child: SizedBox(
                          height: 200,
                          child: BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              maxY: progressData.map((p) => p.pointsEarned.toDouble()).reduce((a, b) => a > b ? a : b) * 1.2,
                              barTouchData: BarTouchData(enabled: false),
                              titlesData: FlTitlesData(
                                show: true,
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      if (value.toInt() >= progressData.length) {
                                        return const SizedBox.shrink();
                                      }
                                      final date = progressData[value.toInt()].date;
                                      return Text(
                                        '${date.day}/${date.month}',
                                        style: AppTextStyles.caption,
                                      );
                                    },
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                topTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                rightTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                              ),
                              borderData: FlBorderData(show: false),
                              barGroups: progressData.asMap().entries.map((entry) {
                                return BarChartGroupData(
                                  x: entry.key,
                                  barRods: [
                                    BarChartRodData(
                                      toY: entry.value.pointsEarned.toDouble(),
                                      color: AppColors.primary,
                                      width: 16,
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(4),
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: AppTextStyles.bodyLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(AchievementModel achievement, bool isUnlocked) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth;
        final iconSize = cardWidth * 0.25; // 25% of card width
        
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
            border: Border.all(
              color: isUnlocked ? AppColors.success : Colors.grey[300]!,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    _getIconData(achievement.iconName),
                    size: iconSize.clamp(32.0, 48.0),
                    color: isUnlocked ? AppColors.warning : Colors.grey[400],
                  ),
                  if (!isUnlocked)
                    Icon(
                      Icons.lock,
                      size: (iconSize * 0.5).clamp(16.0, 24.0),
                      color: Colors.grey[600],
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Flexible(
                child: Text(
                  achievement.title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isUnlocked ? AppColors.textPrimary : AppColors.textLight,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 4),
              Flexible(
                child: Text(
                  achievement.description,
                  style: AppTextStyles.caption.copyWith(
                    color: isUnlocked ? AppColors.textSecondary : AppColors.textLight,
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: isUnlocked
                        ? AppColors.success.withOpacity(0.2)
                        : Colors.grey[200],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${achievement.pointsRequired} puan',
                    style: AppTextStyles.caption.copyWith(
                      color: isUnlocked ? AppColors.success : AppColors.textLight,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'flag':
        return Icons.flag;
      case 'local_fire_department':
        return Icons.local_fire_department;
      case 'whatshot':
        return Icons.whatshot;
      case 'school':
        return Icons.school;
      case 'workspace_premium':
        return Icons.workspace_premium;
      case 'star':
        return Icons.star;
      case 'stars':
        return Icons.stars;
      default:
        return Icons.emoji_events;
    }
  }
}
