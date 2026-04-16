class MoodMapper {
  /// Maps a 1-5 integer to a visual emoji representation
  static String getMoodEmoji(int mood) {
    switch (mood) {
      case 1:
        return '😫'; // Stressed / Poor
      case 2:
        return '😕'; // Sad
      case 3:
        return '😐'; // Neutral
      case 4:
        return '🙂'; // Good
      case 5:
        return '🤩'; // Excellent
      default:
        return '😐';
    }
  }

  /// Maps a 1-5 integer to a text label
  static String getMoodLabel(int mood) {
    switch (mood) {
      case 1:
        return 'Stressed';
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
