import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/habit_model.dart';
import '../utils/constants.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final _authService = AuthService();
  final _firestoreService = FirestoreService();
  
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<HabitModel> _habits = [];

  // Alışkanlıklar için renk paleti
  static const List<Color> habitColors = [
    Color(0xFF6C63FF), // Mor
    Color(0xFFFF6584), // Pembe
    Color(0xFF00B894), // Yeşil
    Color(0xFFFDCB6E), // Sarı
    Color(0xFF00CEC9), // Turkuaz
    Color(0xFFFF7675), // Kırmızı
    Color(0xFF74B9FF), // Mavi
    Color(0xFFA29BFE), // Açık mor
    Color(0xFFFD79A8), // Açık pembe
    Color(0xFF55EFC4), // Açık yeşil
  ];

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  Color getHabitColor(int colorIndex) {
    return habitColors[colorIndex % habitColors.length];
  }

  bool _isDateCompleted(DateTime date, HabitModel habit) {
    return habit.completedDates.any((completedDate) =>
        completedDate.year == date.year &&
        completedDate.month == date.month &&
        completedDate.day == date.day);
  }

  int _getCompletedHabitsCount(DateTime date) {
    return _habits.where((habit) => _isDateCompleted(date, habit)).length;
  }

  // Belirli bir tarihteki aktif alışkanlıkları getir
  List<HabitModel> _getActiveHabitsForDate(DateTime date) {
    return _habits.where((habit) => habit.isActiveOnDate(date)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: StreamBuilder<List<HabitModel>>(
        stream: _firestoreService.getUserHabits(_authService.currentUser!.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('Veri yüklenemedi'));
          }

          _habits = snapshot.data!;

          return SingleChildScrollView(
            child: Column(
              children: [
                // Takvim
                Container(
                  margin: const EdgeInsets.all(AppDimensions.paddingMedium),
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
                  child: TableCalendar(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    calendarFormat: CalendarFormat.month,
                    startingDayOfWeek: StartingDayOfWeek.monday,
                    headerStyle: HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: AppTextStyles.h4,
                      leftChevronIcon: const Icon(Icons.chevron_left, color: AppColors.primary),
                      rightChevronIcon: const Icon(Icons.chevron_right, color: AppColors.primary),
                    ),
                    calendarStyle: CalendarStyle(
                      todayDecoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      markerDecoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                      markersMaxCount: 1,
                    ),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    },
                    eventLoader: (day) {
                      final count = _getCompletedHabitsCount(day);
                      return List.generate(count > 0 ? 1 : 0, (index) => 'completed');
                    },
                    // Custom cell builder for habit date ranges
                    calendarBuilders: CalendarBuilders(
                      defaultBuilder: (context, day, focusedDay) {
                        final activeHabits = _getActiveHabitsForDate(day);
                        if (activeHabits.isEmpty) return null;
                        
                        return _buildCalendarCell(day, activeHabits, false, false);
                      },
                      todayBuilder: (context, day, focusedDay) {
                        final activeHabits = _getActiveHabitsForDate(day);
                        if (activeHabits.isEmpty) return null;
                        
                        return _buildCalendarCell(day, activeHabits, true, false);
                      },
                      selectedBuilder: (context, day, focusedDay) {
                        final activeHabits = _getActiveHabitsForDate(day);
                        if (activeHabits.isEmpty) return null;
                        
                        return _buildCalendarCell(day, activeHabits, false, true);
                      },
                    ),
                  ),
                ),

                // Seçili günün detayları
                if (_selectedDay != null) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingMedium,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedDay!.day == DateTime.now().day &&
                                  _selectedDay!.month == DateTime.now().month &&
                                  _selectedDay!.year == DateTime.now().year
                              ? 'Bugün'
                              : '${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}',
                          style: AppTextStyles.h3,
                        ),
                        const SizedBox(height: 16),
                        
                        // Sadece seçili tarihte aktif olan alışkanlıkları göster
                        Builder(
                          builder: (context) {
                            final activeHabits = _habits.where((habit) => 
                              habit.isActiveOnDate(_selectedDay!)
                            ).toList();
                            
                            if (activeHabits.isEmpty) {
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                                  child: Text(
                                    'Bu tarihte aktif alışkanlık yok',
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
                              itemCount: activeHabits.length,
                              itemBuilder: (context, index) {
                                final habit = activeHabits[index];
                                final isCompleted = _isDateCompleted(_selectedDay!, habit);
                                
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
                                    border: Border.all(
                                      color: isCompleted
                                          ? AppColors.success
                                          : Colors.grey[300]!,
                                      width: 2,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        isCompleted
                                            ? Icons.check_circle
                                            : Icons.radio_button_unchecked,
                                        color: isCompleted
                                            ? AppColors.success
                                            : AppColors.textLight,
                                        size: 28,
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
                                                decoration: isCompleted
                                                    ? TextDecoration.lineThrough
                                                    : null,
                                              ),
                                            ),
                                            if (habit.description.isNotEmpty) ...[
                                              const SizedBox(height: 4),
                                              Text(
                                                habit.description,
                                                style: AppTextStyles.bodySmall,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                      if (habit.currentStreak > 0)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.warning.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(
                                                Icons.local_fire_department,
                                                size: 16,
                                                color: AppColors.warning,
                                              ),
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
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
                
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  // Takvim hücresi oluştur
  Widget _buildCalendarCell(DateTime day, List<HabitModel> activeHabits, bool isToday, bool isSelected) {
    // En fazla 3 alışkanlık göster
    final habitsToShow = activeHabits.take(3).toList();
    
    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: isSelected 
            ? AppColors.primary 
            : isToday 
                ? AppColors.primary.withOpacity(0.3) 
                : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          // Renkli çizgiler (alışkanlık göstergeleri)
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Row(
              children: habitsToShow.map((habit) {
                final color = getHabitColor(habit.colorIndex);
                final isCompleted = _isDateCompleted(day, habit);
                
                return Container(
                  width: 3,
                  margin: const EdgeInsets.only(right: 1),
                  decoration: BoxDecoration(
                    color: isCompleted ? color : color.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              }).toList(),
            ),
          ),
          
          // Gün numarası
          Center(
            child: Text(
              '${day.day}',
              style: TextStyle(
                color: isSelected || isToday ? Colors.white : Colors.black87,
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          
          // Tamamlanma göstergesi (yeşil nokta)
          if (habitsToShow.any((h) => _isDateCompleted(day, h)))
            Positioned(
              bottom: 4,
              right: 4,
              child: Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
