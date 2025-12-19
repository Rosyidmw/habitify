import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/habit_model.dart';
import '../core/database_helper.dart';

class HabitProvider extends ChangeNotifier {
  List<Habit> _habits = [];
  bool _isLoading = false;

  Map<int, int> _weeklyData = {};
  Map<int, int> _monthlyData = {};

  List<Habit> get habits => _habits;
  bool get isLoading => _isLoading;
  Map<int, int> get weeklyData => _weeklyData;
  Map<int, int> get monthlyData => _monthlyData;

  String get _todayDate {
    final now = DateTime.now();
    return DateFormat('yyyy-MM-dd').format(now);
  }

  Future<void> loadHabits() async {
    _isLoading = true;
    notifyListeners();

    final rawHabits = await DatabaseHelper.instance.readAllHabits();
    List<Habit> processedHabits = [];
    for (var habit in rawHabits) {
      final isCompletedToday = await DatabaseHelper.instance
          .isHabitCompletedToday(habit.id!, _todayDate);
      processedHabits.add(habit.copyWith(isCompleted: isCompletedToday));
    }
    _habits = processedHabits;

    await _loadPeriodStats();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadPeriodStats() async {
    final now = DateTime.now();

    final monday = now.subtract(Duration(days: now.weekday - 1));
    final sunday = monday.add(const Duration(days: 6));

    final weekStart = DateFormat('yyyy-MM-dd').format(monday);
    final weekEnd = DateFormat('yyyy-MM-dd').format(sunday);

    final rawWeekly = await DatabaseHelper.instance.getHistoryInRange(
      weekStart,
      weekEnd,
    );

    _weeklyData = {0: 0, 1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0};
    rawWeekly.forEach((dateStr, count) {
      final date = DateTime.parse(dateStr);

      final index = date.weekday - 1;
      _weeklyData[index] = count;
    });

    final monthStartObj = DateTime(now.year, now.month, 1);

    final monthEndObj = DateTime(now.year, now.month + 1, 0);

    final monthStart = DateFormat('yyyy-MM-dd').format(monthStartObj);
    final monthEnd = DateFormat('yyyy-MM-dd').format(monthEndObj);

    final rawMonthly = await DatabaseHelper.instance.getHistoryInRange(
      monthStart,
      monthEnd,
    );

    _monthlyData = {};

    for (int i = 1; i <= monthEndObj.day; i++) {
      _monthlyData[i] = 0;
    }

    rawMonthly.forEach((dateStr, count) {
      final date = DateTime.parse(dateStr);
      _monthlyData[date.day] = count;
    });
  }

  Future<void> addHabit(String title) async {
    final newHabit = Habit(title: title, createdAt: DateTime.now());
    await DatabaseHelper.instance.create(newHabit);
    await loadHabits();
  }

  Future<void> deleteHabit(int id) async {
    await DatabaseHelper.instance.delete(id);
    await loadHabits();
  }

  Future<void> toggleHabit(Habit habit) async {
    await DatabaseHelper.instance.toggleHabitHistory(habit.id!, _todayDate);
    await loadHabits();
  }

  Future<void> restoreHabit(Habit habit) async {
    await DatabaseHelper.instance.create(habit);
    await loadHabits();
  }
}
