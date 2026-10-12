import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/reading_plans_data.dart';
import '../models/reading_plan.dart';

class ReadingPlanSessionState {
  final bool isLoading;
  final Map<String, Set<int>> completedDaysByPlan;
  final List<ReadingPlan> customPlans;
  final ReadingPlan? activeSessionPlan;
  final int? activeSessionDay;

  const ReadingPlanSessionState({
    this.isLoading = true,
    this.completedDaysByPlan = const {},
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

  ReadingPlanSessionState copyWith({
    bool? isLoading,
    Map<String, Set<int>>? completedDaysByPlan,
    List<ReadingPlan>? customPlans,
    ReadingPlan? activeSessionPlan,
    int? activeSessionDay,
    bool clearSession = false,
  }) {
    return ReadingPlanSessionState(
      isLoading: isLoading ?? this.isLoading,
      completedDaysByPlan: completedDaysByPlan ?? this.completedDaysByPlan,
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

  Future<void> loadAll() async {
    final prefs = await SharedPreferences.getInstance();

    // Load custom plans
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

    for (final plan in allPlans) {
      final key = 'plan_${plan.id}_completed';
      final completed = prefs.getStringList(key) ?? [];
      completedMap[plan.id] = completed.map((e) => int.tryParse(e) ?? 0).where((e) => e > 0).toSet();
    }

    state = state.copyWith(
      isLoading: false,
      customPlans: loadedCustomPlans,
      completedDaysByPlan: completedMap,
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

  void startReadingSession(ReadingPlan plan, int day) {
    state = state.copyWith(
      activeSessionPlan: plan,
      activeSessionDay: day,
    );
  }

  void clearActiveSession() {
    state = state.copyWith(clearSession: true);
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
      state = state.copyWith(activeSessionDay: nextDay);
      return plan.passages[(nextDay - 1).clamp(0, plan.passages.length - 1)];
    } else {
      clearActiveSession();
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
