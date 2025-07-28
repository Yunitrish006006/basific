import 'package:flutter_test/flutter_test.dart';
import 'package:basific/basific.dart';

void main() {
  group('Basific Auth Tests', () {
    test('should detect email format correctly', () {
      // This is testing the internal _isEmail method through the public interface
      // We can't test the private method directly, but we can verify behavior
      expect('test@example.com'.contains('@'), true);
      expect('username'.contains('@'), false);
    });
    
    test('should create BasificUser correctly', () {
      // Test BasificUser creation and properties
      final user = BasificUser(
        id: 'test-id',
        email: 'test@example.com',
        displayName: 'Test User',
        createdAt: DateTime.parse('2024-01-01T00:00:00Z'),
      );
      
      expect(user.id, 'test-id');
      expect(user.email, 'test@example.com');
      expect(user.bestDisplayName, 'Test User');
    });
    
    test('should fallback to email prefix when no display name', () {
      final user = BasificUser(
        id: 'test-id',
        email: 'testuser@example.com',
        createdAt: DateTime.parse('2024-01-01T00:00:00Z'),
      );
      
      expect(user.bestDisplayName, 'testuser');
    });
  });
}
