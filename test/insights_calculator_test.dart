import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:focus_pulse/core/utils/insights_calculator.dart';
import 'package:focus_pulse/data/models/tracker_session.dart';

// Helper to quickly create a TrackerSession for testing.
// We pass a [daysAgo] offset so we can simulate sessions on different days.
TrackerSession makeSession({
  required int daysAgo,
  double hours = 2.0,
  int mood = 3,
  String subject = 'Math',
}) {
  return TrackerSession(
    id: UniqueKey().toString(),
    subject: subject,
    hours: hours,
    mood: mood,
    date: DateTime.now().subtract(Duration(days: daysAgo)),
  );
}

void main() {
  // ─────────────────────────────────────────────────────────────
  // getMoodInsight() tests
  // ─────────────────────────────────────────────────────────────
  group('InsightsCalculator.getMoodInsight', () {
    test('returns default message when session list is empty', () {
      final result = InsightsCalculator.getMoodInsight([]);
      expect(result, contains('Add data'));
    });

    test('identifies the mood with highest average hours', () {
      final sessions = [
        // mood 5 (Excellent) → 6 hours average
        makeSession(daysAgo: 0, mood: 5, hours: 6),
        makeSession(daysAgo: 1, mood: 5, hours: 6),
        // mood 3 (Neutral) → 2 hours average
        makeSession(daysAgo: 2, mood: 3, hours: 2),
      ];
      final result = InsightsCalculator.getMoodInsight(sessions);
      expect(result, contains('Excellent'));
    });

    test('returns a non-empty insight string for any valid sessions', () {
      final sessions = [makeSession(daysAgo: 0, mood: 4, hours: 3)];
      final result = InsightsCalculator.getMoodInsight(sessions);
      expect(result, isNotEmpty);
      expect(result, contains('Insight:'));
    });

    test('handles single-session correctly', () {
      final sessions = [makeSession(daysAgo: 0, mood: 2, hours: 1)];
      final result = InsightsCalculator.getMoodInsight(sessions);
      expect(result, contains('Sad'));
    });
  });
}
