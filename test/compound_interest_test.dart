import 'package:flutter_test/flutter_test.dart';
import 'package:my_kid_money/models/account.dart';
import 'package:my_kid_money/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Compound Interest Calculation', () {
    late Account account;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await StorageService.init();

      account = Account(
        name: 'Test Account',
        balance: 1000.0,
        tax: 10.0, // 10% interest
        lastInterestDate: DateTime(DateTime.now().year, DateTime.now().month - 2, DateTime.now().day),
      );

      await StorageService.addAccount(account);
      await StorageService.setCurrentAccountId(account.id);
    });

    test('should apply compound interest correctly for multiple months', () async {
      // Arrange
      final initialBalance = account.balance;
      final interestRate = account.tax!;

      // Act
      await StorageService.init(); // This should trigger the interest calculation
      final updatedAccount = await StorageService.getAccount(account.id);

      // Assert
      expect(updatedAccount, isNotNull);
      expect(updatedAccount!.transactions.length, equals(2));

      // Month 1
      final interest1 = initialBalance * (interestRate / 100);
      final balance1 = initialBalance + interest1;
      expect(updatedAccount.transactions[0].value, equals(interest1));
      expect(updatedAccount.transactions[0].balanceAfter, equals(balance1));
      expect(updatedAccount.transactions[0].description, equals('Juros mensal'));
      
      // Month 2
      final interest2 = balance1 * (interestRate / 100);
      final balance2 = balance1 + interest2;
      expect(updatedAccount.transactions[1].value, equals(interest2));
      expect(updatedAccount.transactions[1].balanceAfter, equals(balance2));
      expect(updatedAccount.transactions[1].description, equals('Juros mensal'));
      
      expect(updatedAccount.balance, equals(balance2));
    });
  });
}
