import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../core/utils/insights_calculator.dart';
import '../../core/utils/mood_mapper.dart';
import '../../data/models/tracker_session.dart';

class AnalyticsTab extends StatelessWidget {
  const AnalyticsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final sessionBox = Hive.box<TrackerSession>('sessions');

    return ValueListenableBuilder(
      valueListenable: sessionBox.listenable(),
      builder: (context, Box<TrackerSession> box, _) {
        final sessions = box.values.toList();

        if (sessions.isEmpty) {
          return const Center(
            child: Text('No data yet. Start studying to see insights!'),
          );
        }

        final report = _AnalyticsReport.calculate(sessions);
        final screenWidth = MediaQuery.of(context).size.width;
        final isWide = screenWidth > 600;
        final horizontalPadding = isWide ? 32.0 : 16.0;

        return SingleChildScrollView(
          padding: EdgeInsets.all(horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _MoodInsightCard(insight: report.moodInsight),
              const SizedBox(height: 16),
              _TopSubjectCard(
                subject: report.topSubject,
                hours: report.topSubjectHours,
              ),
              const SizedBox(height: 24),
              _FocusLineChart(spots: report.lineSpots),
              const SizedBox(height: 24),
              const Text(
                'Hours by Subject',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _SubjectBarChart(
                subjects: report.subjects,
                barGroups: report.barGroups,
                maxY: report.maxBarY,
              ),
              const SizedBox(height: 32),
              _MoodPieChart(
                sections: report.pieSections,
                moodHours: report.moodHours,
              ),
              const SizedBox(height: 48),
            ],
          ),
        );
      },
    );
  }
}

class _AnalyticsReport {
  final String moodInsight;
  final String topSubject;
  final double topSubjectHours;
  final List<FlSpot> lineSpots;
  final List<PieChartSectionData> pieSections;
  final Map<int, double> moodHours;
  final List<String> subjects;
  final List<BarChartGroupData> barGroups;
  final double maxBarY;

  _AnalyticsReport({
    required this.moodInsight,
    required this.topSubject,
    required this.topSubjectHours,
    required this.lineSpots,
    required this.pieSections,
    required this.moodHours,
    required this.subjects,
    required this.barGroups,
    required this.maxBarY,
  });

  factory _AnalyticsReport.calculate(List<TrackerSession> sessions) {
    final Map<String, double> subjectHours = {};
    final Map<DateTime, double> dailyHours = {};
    final Map<int, double> moodHours = {};
    double totalHours = 0;

    for (var session in sessions) {
      totalHours += session.hours;
      subjectHours[session.subject] =
          (subjectHours[session.subject] ?? 0) + session.hours;
      moodHours[session.mood] = (moodHours[session.mood] ?? 0) + session.hours;
      final date = DateUtils.dateOnly(session.date);
      dailyHours[date] = (dailyHours[date] ?? 0) + session.hours;
    }

    String topSubject = 'N/A';
    double topSubjectHours = 0;
    subjectHours.forEach((subject, hours) {
      if (hours > topSubjectHours) {
        topSubjectHours = hours;
        topSubject = subject;
      }
    });

    final now = DateTime.now();
    final List<DateTime> last30Days = List.generate(
      30,
      (i) => DateUtils.dateOnly(now.subtract(Duration(days: 29 - i))),
    );
    final List<FlSpot> lineSpots = [];
    for (int i = 0; i < last30Days.length; i++) {
      final day = last30Days[i];
      lineSpots.add(FlSpot(i.toDouble(), dailyHours[day] ?? 0));
    }

    final moodColors = [
      Colors.redAccent,
      Colors.orangeAccent,
      Colors.grey,
      Colors.lightGreen,
      Colors.greenAccent,
    ];

    final List<PieChartSectionData> pieSections = [];
    moodHours.forEach((mood, hours) {
      final percent = totalHours == 0 ? 0 : (hours / totalHours) * 100;
      pieSections.add(
        PieChartSectionData(
          value: hours,
          title: '${percent.toStringAsFixed(1)}%',
          color: moodColors[(mood - 1).clamp(0, 4)],
          radius: 50,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    });

    final subjects = subjectHours.keys.toList();
    final List<BarChartGroupData> barGroups = [];
    double maxBarY = 0;
    for (int i = 0; i < subjects.length; i++) {
      final hours = subjectHours[subjects[i]]!;
      if (hours > maxBarY) maxBarY = hours;
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: hours,
              color: Colors.teal, // Fallback if theme context is not accessible
              width: 24,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(8),
              ),
            ),
          ],
        ),
      );
    }

    return _AnalyticsReport(
      moodInsight: InsightsCalculator.getMoodInsight(sessions),
      topSubject: topSubject,
      topSubjectHours: topSubjectHours,
      lineSpots: lineSpots,
      pieSections: pieSections,
      moodHours: moodHours,
      subjects: subjects,
      barGroups: barGroups,
      maxBarY: maxBarY + (maxBarY * 0.2),
    );
  }
}

class _MoodInsightCard extends StatelessWidget {
  final String insight;
  const _MoodInsightCard({required this.insight});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Icon(
              Icons.psychology,
              size: 40,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                insight,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopSubjectCard extends StatelessWidget {
  final String subject;
  final double hours;
  const _TopSubjectCard({required this.subject, required this.hours});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.secondaryContainer,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 20.0),
        child: Column(
          children: [
            const Text(
              'Top Performing Subject',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              subject,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSecondaryContainer,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${hours.toStringAsFixed(1)} Total Hours',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(
                  context,
                ).colorScheme.onSecondaryContainer.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FocusLineChart extends StatelessWidget {
  final List<FlSpot> spots;
  const _FocusLineChart({required this.spots});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Focus Hours (Last 30 Days)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Theme.of(context).colorScheme.primary,
                      barWidth: 4,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubjectBarChart extends StatelessWidget {
  final List<String> subjects;
  final List<BarChartGroupData> barGroups;
  final double maxY;

  const _SubjectBarChart({
    required this.subjects,
    required this.barGroups,
    required this.maxY,
  });

  @override
  Widget build(BuildContext context) {
    // Update bar colors to match theme
    final themedBarGroups = barGroups.map((group) {
      return group.copyWith(
        barRods: group.barRods.map((rod) {
          return rod.copyWith(color: Theme.of(context).colorScheme.primary);
        }).toList(),
      );
    }).toList();

    return SizedBox(
      height: 250,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY,
          barTouchData: BarTouchData(enabled: true),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 42,
                getTitlesWidget: (double value, TitleMeta meta) {
                  if (value.toInt() >= 0 && value.toInt() < subjects.length) {
                    return SideTitleWidget(
                      meta: meta,
                      space: 8,
                      angle: subjects.length > 4 ? -0.5 : 0,
                      child: Text(
                        subjects[value.toInt()],
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: themedBarGroups,
        ),
      ),
    );
  }
}

class _MoodPieChart extends StatelessWidget {
  final List<PieChartSectionData> sections;
  final Map<int, double> moodHours;

  const _MoodPieChart({required this.sections, required this.moodHours});

  @override
  Widget build(BuildContext context) {
    final moodColors = [
      Colors.redAccent,
      Colors.orangeAccent,
      Colors.grey,
      Colors.lightGreen,
      Colors.greenAccent,
    ];

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mood Distribution',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: sections,
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: moodHours.keys.map((mood) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: moodColors[(mood - 1).clamp(0, 4)],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${MoodMapper.getMoodEmoji(mood)} ${MoodMapper.getMoodLabel(mood)}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            const Text(
              'Breakdown of how you felt during study sessions.',
              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}
