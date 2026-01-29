import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my_kid_money/models/account.dart';
import 'package:my_kid_money/services/storage_service.dart';

void main() {
  group('Interest Calculation', () {
    late Account account;

    setUp(() async {
      // Set up a mock SharedPreferences for testing
      SharedPreferences.setMockInitialValues({});
      await StorageService.init();

      // Create a new account for each test
      account = Account(
        name: 'Test Account',
        balance: 1000.0,
        tax: 10.0, // 10% interest
        lastInterestDate: DateTime.now().subtract(const Duration(days: 31)),
      );

      await StorageService.addAccount(account);
      await StorageService.setCurrentAccountId(account.id);
    });

    test('should apply interest correctly', () async {
      // Arrange
      final initialBalance = account.balance;
      final interestRate = account.tax!;
      final expectedInterest = initialBalance * (interestRate / 100);
      final expectedBalance = initialBalance + expectedInterest;

      // Act
      await StorageService.init(); // This should trigger the interest calculation
      final updatedAccount = await StorageService.getCurrentAccount();

      // Assert
      expect(updatedAccount, isNotNull);
      expect(updatedAccount!.balance, equals(expectedBalance));
      expect(updatedAccount.transactions.length, equals(1));
      expect(updatedAccount.transactions.first.value, equals(expectedInterest));
      expect(
        updatedAccount.transactions.first.description,
        equals('Juros mensal'),
      );
    });
  });
}
