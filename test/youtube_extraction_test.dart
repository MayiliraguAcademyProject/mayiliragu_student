import 'package:flutter_test/flutter_test.dart';
import 'package:Mayiliragu/modules/lessons/controllers/lesson_controller.dart';

void main() {
  group('YouTube ID Extraction Tests', () {
    test('extracts ID from direct URLs', () {
      expect(LessonController.extractYoutubeId('https://www.youtube.com/watch?v=dQw4w9WgXcQ'), 'dQw4w9WgXcQ');
      expect(LessonController.extractYoutubeId('http://youtube.com/watch?v=dQw4w9WgXcQ'), 'dQw4w9WgXcQ');
      expect(LessonController.extractYoutubeId('https://youtu.be/dQw4w9WgXcQ'), 'dQw4w9WgXcQ');
      expect(LessonController.extractYoutubeId('https://www.youtube.com/embed/dQw4w9WgXcQ'), 'dQw4w9WgXcQ');
      expect(LessonController.extractYoutubeId('https://youtube.com/watch?v=dQw4w9WgXcQ&feature=share'), 'dQw4w9WgXcQ');
      expect(LessonController.extractYoutubeId('https://www.youtube.com/live/cd7OycBJ5-k?si=2qd-g2wA_4ACPYnk'), 'cd7OycBJ5-k');
      expect(LessonController.extractYoutubeId('https://youtube.com/shorts/dQw4w9WgXcQ'), 'dQw4w9WgXcQ');
    });

    test('extracts ID from bare 11-char string', () {
      expect(LessonController.extractYoutubeId('dQw4w9WgXcQ'), 'dQw4w9WgXcQ');
      expect(LessonController.extractYoutubeId('aBc123_df-g'), 'aBc123_df-g');
    });

    test('returns null for invalid inputs', () {
      expect(LessonController.extractYoutubeId(''), null);
      expect(LessonController.extractYoutubeId(null), null);
      expect(LessonController.extractYoutubeId('short'), null);
      expect(LessonController.extractYoutubeId('https://google.com'), null);
      expect(LessonController.extractYoutubeId('123456789012'), null); // 12 chars
    });
  });
}
