import 'package:flutter_test/flutter_test.dart';

import 'package:sample_app/models/user_model.dart';

void main() {
  group('SampleUserModel', () {
    test('stores username, userId, and imageURL', () {
      final user = SampleUserModel('Alice', 'uid_alice', 'https://img.com/alice.png');

      expect(user.username, 'Alice');
      expect(user.userId, 'uid_alice');
      expect(user.imageURL, 'https://img.com/alice.png');
    });

    test('handles empty strings', () {
      final user = SampleUserModel('', '', '');

      expect(user.username, isEmpty);
      expect(user.userId, isEmpty);
      expect(user.imageURL, isEmpty);
    });

    test('stores special characters in username', () {
      final user = SampleUserModel('José García', 'uid_jose', '');

      expect(user.username, 'José García');
    });
  });
}
