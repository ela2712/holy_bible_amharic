import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/reading_plans_data.dart';
import '../models/reading_plan.dart';

class ReadingPlanSessionState {
  final bool isLoading;
  final Map<String, Set<int>> completedDaysByPlan;
  final Map<String, Map<int, Set<int>>> completedChaptersByPlanAndDay;
  final List<ReadingPlan> customPlans;
  final ReadingPlan? activeSessionPlan;
  final int? activeSessionDay;

  const ReadingPlanSessionState({
    this.isLoading = true,
    this.completedDaysByPlan = const {},
    this.completedChaptersByPlanAndDay = const {},
    this.customPlans = const [],
    this.activeSessionPlan,
    this.activeSessionDay,
  });

  List<ReadingPlan> get allAvailablePlans => [
        ...customPlans,
        ...ReadingPlansData.allPlans,
      ];

  DailyReadingPassage? get activePassage {
    if (activeSessionPlan == null || activeSessionDay == null) return null;
    final idx = (activeSessionDay! - 1).clamp(0, activeSessionPlan!.passages.length - 1);
    return activeSessionPlan!.passages[idx];
  }

  bool isDayCompleted(String planId, int day) {
    return completedDaysByPlan[planId]?.contains(day) ?? false;
  }

  bool isChapterCompleted(String planId, int day, int chapter) {
    return completedChaptersByPlanAndDay[planId]?[day]?.contains(chapter) ?? false;
  }

  Set<int> getReadChapters(String planId, int day) {
    return completedChaptersByPlanAndDay[planId]?[day] ?? <int>{};
  }

  int getReadChaptersCount(String planId, int day) {
    return getReadChapters(planId, day).length;
  }

  double getDayProgress(String planId, int day, int totalChaptersInDay) {
    if (isDayCompleted(planId, day)) return 1.0;
    if (totalChaptersInDay <= 0) return 0.0;
    final count = getReadChaptersCount(planId, day);
    return (count / totalChaptersInDay).clamp(0.0, 1.0);
  }

  ReadingPlanSessionState copyWith({
    bool? isLoading,
    Map<String, Set<int>>? completedDaysByPlan,
    Map<String, Map<int, Set<int>>>? completedChaptersByPlanAndDay,
    List<ReadingPlan>? customPlans,
    ReadingPlan? activeSessionPlan,
    int? activeSessionDay,
    bool clearSession = false,
  }) {
    return ReadingPlanSessionState(
      isLoading: isLoading ?? this.isLoading,
      completedDaysByPlan: completedDaysByPlan ?? this.completedDaysByPlan,
      completedChaptersByPlanAndDay: completedChaptersByPlanAndDay ?? this.completedChaptersByPlanAndDay,
      customPlans: customPlans ?? this.customPlans,
      activeSessionPlan: clearSession ? null : (activeSessionPlan ?? this.activeSessionPlan),
      activeSessionDay: clearSession ? null : (activeSessionDay ?? this.activeSessionDay),
    );
  }
}

class ReadingPlanSessionNotifier extends StateNotifier<ReadingPlanSessionState> {
  ReadingPlanSessionNotifier() : super(const ReadingPlanSessionState()) {
    loadAll();
  }

  static const String _prefActivePlanId = 'active_reading_plan_id_v2';
  static const String _prefActivePlanDay = 'active_reading_plan_day_v2';

  Future<void> loadAll() async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Load custom plans
    final customJsonList = prefs.getStringList('user_custom_plans_v1') ?? [];
    final loadedCustomPlans = <ReadingPlan>[];
    for (final raw in customJsonList) {
      try {
        final map = json.decode(raw) as Map<String, dynamic>;
        final id = map['id'] as String;
        final title = map['title'] as String;
        final scopeKey = map['scopeKey'] as String;
        final totalDays = map['totalDays'] as int;
        loadedCustomPlans.add(
          ReadingPlansData.buildCustomPlan(
            id: id,
            title: title,
            scopeKey: scopeKey,
            totalDays: totalDays,
          ),
        );
      } catch (_) {}
    }

    final allPlans = [...loadedCustomPlans, ...ReadingPlansData.allPlans];
    final completedMap = <String, Set<int>>{};
    final chaptersMap = <String, Map<int, Set<int>>>{};

    for (final plan in allPlans) {
      // Completed Days
      final key = 'plan_${plan.id}_completed';
      final completed = prefs.getStringList(key) ?? [];
      completedMap[plan.id] = completed.map((e) => int.tryParse(e) ?? 0).where((e) => e > 0).toSet();

      // Read Chapters per day
      final dayChapters = <int, Set<int>>{};
      for (final passage in plan.passages) {
        final chKey = 'plan_${plan.id}_day_${passage.day}_chapters';
        final rawChapters = prefs.getStringList(chKey) ?? [];
        if (rawChapters.isNotEmpty) {
          dayChapters[passage.day] = rawChapters.map((e) => int.tryParse(e) ?? 0).where((e) => e > 0).toSet();
        }
      }
      if (dayChapters.isNotEmpty) {
        chaptersMap[plan.id] = dayChapters;
      }
    }

    // 2. Restore persisted active session
    ReadingPlan? restoredPlan;
    int? restoredDay;
    final savedActiveId = prefs.getString(_prefActivePlanId);
    final savedActiveDay = prefs.getInt(_prefActivePlanDay);

    if (savedActiveId != null && savedActiveDay != null) {
      for (final p in allPlans) {
        if (p.id == savedActiveId) {
          restoredPlan = p;
          restoredDay = savedActiveDay.clamp(1, p.totalDays);
          break;
        }
      }
    }

    state = state.copyWith(
      isLoading: false,
      customPlans: loadedCustomPlans,
      completedDaysByPlan: completedMap,
      completedChaptersByPlanAndDay: chaptersMap,
      activeSessionPlan: restoredPlan,
      activeSessionDay: restoredDay,
    );
  }

  Future<void> toggleDayComplete(String planId, int day) async {
    final prefs = await SharedPreferences.getInstance();
    final updatedMap = Map<String, Set<int>>.from(state.completedDaysByPlan);
    final planSet = Set<int>.from(updatedMap[planId] ?? <int>{});

    if (planSet.contains(day)) {
      planSet.remove(day);
    } else {
      planSet.add(day);
    }
    updatedMap[planId] = planSet;

    state = state.copyWith(completedDaysByPlan: updatedMap);

    await prefs.setStringList(
      'plan_${planId}_completed',
      planSet.map((e) => e.toString()).toList(),
    );
  }

  Future<void> startReadingSession(ReadingPlan plan, int day) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefActivePlanId, plan.id);
    await prefs.setInt(_prefActivePlanDay, day);

    state = state.copyWith(
      activeSessionPlan: plan,
      activeSessionDay: day,
    );
  }

  Future<void> clearActiveSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefActivePlanId);
    await prefs.remove(_prefActivePlanDay);

    state = state.copyWith(clearSession: true);
  }

  /// Records a chapter as read for a given plan day.
  /// If all chapters in the day's assigned range are now read, automatically marks the day completed!
  Future<bool> markChapterCompleted({
    required String planId,
    required int day,
    required int chapter,
    required int totalChaptersInDay,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final allPlanChapters = Map<String, Map<int, Set<int>>>.from(state.completedChaptersByPlanAndDay);
    final dayMap = Map<int, Set<int>>.from(allPlanChapters[planId] ?? <int, Set<int>>{});
    final chSet = Set<int>.from(dayMap[day] ?? <int>{});

    if (!chSet.contains(chapter)) {
      chSet.add(chapter);
      dayMap[day] = chSet;
      allPlanChapters[planId] = dayMap;

      await prefs.setStringList(
        'plan_${planId}_day_${day}_chapters',
        chSet.map((e) => e.toString()).toList(),
      );

      state = state.copyWith(completedChaptersByPlanAndDay: allPlanChapters);
    }

    // Check if day is fully read
    bool dayCompletedNow = false;
    if (chSet.length >= totalChaptersInDay && !state.isDayCompleted(planId, day)) {
      await toggleDayComplete(planId, day);
      dayCompletedNow = true;
    }

    return dayCompletedNow;
  }

  Future<DailyReadingPassage?> completeActiveDayAndGetNext() async {
    final plan = state.activeSessionPlan;
    final day = state.activeSessionDay;
    if (plan == null || day == null) return null;

    if (!state.isDayCompleted(plan.id, day)) {
      await toggleDayComplete(plan.id, day);
    }

    if (day < plan.totalDays) {
      final nextDay = day + 1;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_prefActivePlanDay, nextDay);

      state = state.copyWith(activeSessionDay: nextDay);
      return plan.passages[(nextDay - 1).clamp(0, plan.passages.length - 1)];
    } else {
      await clearActiveSession();
      return null;
    }
  }

  Future<ReadingPlan> createCustomPlan({
    required String title,
    required String scopeKey,
    required int totalDays,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final id = 'custom_${DateTime.now().millisecondsSinceEpoch}';
    final newPlan = ReadingPlansData.buildCustomPlan(
      id: id,
      title: title.trim().isEmpty ? 'የእኔ የንባብ ዕቅድ' : title.trim(),
      scopeKey: scopeKey,
      totalDays: totalDays,
    );

    final rawList = prefs.getStringList('user_custom_plans_v1') ?? [];
    rawList.insert(
      0,
      json.encode({
        'id': id,
        'title': newPlan.title,
        'scopeKey': scopeKey,
        'totalDays': totalDays,
      }),
    );
    await prefs.setStringList('user_custom_plans_v1', rawList);

    final updatedCustom = [newPlan, ...state.customPlans];
    final updatedCompleted = Map<String, Set<int>>.from(state.completedDaysByPlan);
    updatedCompleted[id] = <int>{};

    state = state.copyWith(
      customPlans: updatedCustom,
      completedDaysByPlan: updatedCompleted,
    );
    return newPlan;
  }

  Future<void> deleteCustomPlan(String planId) async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = prefs.getStringList('user_custom_plans_v1') ?? [];
    rawList.removeWhere((raw) {
      try {
        final map = json.decode(raw) as Map<String, dynamic>;
        return map['id'] == planId;
      } catch (_) {
        return false;
      }
    });
    await prefs.setStringList('user_custom_plans_v1', rawList);
    await prefs.remove('plan_${planId}_completed');

    final updatedCustom = state.customPlans.where((p) => p.id != planId).toList();
    final updatedCompleted = Map<String, Set<int>>.from(state.completedDaysByPlan)..remove(planId);

    final isDeletingActive = state.activeSessionPlan?.id == planId;
    if (isDeletingActive) {
      await clearActiveSession();
    }

    state = state.copyWith(
      customPlans: updatedCustom,
      completedDaysByPlan: updatedCompleted,
      clearSession: isDeletingActive,
    );
  }
}

final readingPlanSessionProvider =
    StateNotifierProvider<ReadingPlanSessionNotifier, ReadingPlanSessionState>((ref) {
  return ReadingPlanSessionNotifier();
});
