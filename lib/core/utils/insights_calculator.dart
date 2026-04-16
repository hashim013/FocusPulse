import '../../data/models/tracker_session.dart';

class InsightsCalculator {
  /// Calculates the mood in which the user has the highest average study hours
  static String getMoodInsight(List<TrackerSession> sessions) {
    if (sessions.isEmpty) {
      return "Insight: Add data to discover your most productive mood.";
    }

    final Map<int, List<double>> moodHours = {};
    for (var session in sessions) {
      if (!moodHours.containsKey(session.mood)) {
        moodHours[session.mood] = [];
      }
      moodHours[session.mood]!.add(session.hours);
    }

    double maxAverage = -1;
    int optimalMood = -1;

    moodHours.forEach((mood, hoursList) {
      final average = hoursList.reduce((a, b) => a + b) / hoursList.length;
      if (average > maxAverage) {
        maxAverage = average;
        optimalMood = mood;
      }
    });

    final moodString = _mapMoodToString(optimalMood);
    return "Insight: You are most productive when your mood is '$moodString'.";
  }

  static String _mapMoodToString(int mood) {
    switch (mood) {
      case 1:
        return 'Stressed / Poor';
      case 2:
        return 'Sad';
      case 3:
        return 'Neutral';
      case 4:
        return 'Good';
      case 5:
        return 'Excellent';
      default:
        return 'Neutral';
    }
  }
}
