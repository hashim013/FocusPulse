import 'package:flutter_test/flutter_test.dart';
import 'package:focus_pulse/core/utils/mood_mapper.dart';

void main() {
  group('MoodMapper.getMoodEmoji', () {
    test('returns stressed emoji for mood 1', () {
      expect(MoodMapper.getMoodEmoji(1), '😫');
    });

    test('returns sad emoji for mood 2', () {
      expect(MoodMapper.getMoodEmoji(2), '😕');
    });

    test('returns neutral emoji for mood 3', () {
      expect(MoodMapper.getMoodEmoji(3), '😐');
    });

    test('returns good emoji for mood 4', () {
      expect(MoodMapper.getMoodEmoji(4), '🙂');
    });

    test('returns excellent emoji for mood 5', () {
      expect(MoodMapper.getMoodEmoji(5), '🤩');
    });

    test('returns neutral emoji for unknown mood values (fallback)', () {
      expect(MoodMapper.getMoodEmoji(0), '😐');
      expect(MoodMapper.getMoodEmoji(99), '😐');
      expect(MoodMapper.getMoodEmoji(-1), '😐');
    });
  });
}
