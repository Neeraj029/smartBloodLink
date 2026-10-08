import 'package:flutter_test/flutter_test.dart';
import 'package:smart_blood_link/utils/compatibility_matrix.dart';

void main() {
  group('Clinical Blood Compatibility Matrix Tests', () {
    test('O- Negative is universal donor', () {
      final allRecipients = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
      for (final recipient in allRecipients) {
        expect(
          CompatibilityMatrix.isCompatible(
            donorGroup: 'O-',
            recipientGroup: recipient,
          ),
          isTrue,
          reason: 'O- must be compatible with $recipient',
        );
      }
    });

    test('AB+ Positive is universal recipient', () {
      final allDonors = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
      for (final donor in allDonors) {
        expect(
          CompatibilityMatrix.isCompatible(
            donorGroup: donor,
            recipientGroup: 'AB+',
          ),
          isTrue,
          reason: 'AB+ recipient must be able to receive $donor',
        );
      }
    });

    test('Identical blood groups are always compatible', () {
      final allGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
      for (final group in allGroups) {
        expect(
          CompatibilityMatrix.isCompatible(
            donorGroup: group,
            recipientGroup: group,
          ),
          isTrue,
          reason: '$group must be compatible with itself',
        );
      }
    });

    test('Rh Positive cannot donate to Rh Negative', () {
      expect(
        CompatibilityMatrix.isCompatible(
          donorGroup: 'O+',
          recipientGroup: 'O-',
        ),
        isFalse,
      );
      expect(
        CompatibilityMatrix.isCompatible(
          donorGroup: 'A+',
          recipientGroup: 'A-',
        ),
        isFalse,
      );
      expect(
        CompatibilityMatrix.isCompatible(
          donorGroup: 'B+',
          recipientGroup: 'B-',
        ),
        isFalse,
      );
      expect(
        CompatibilityMatrix.isCompatible(
          donorGroup: 'AB+',
          recipientGroup: 'AB-',
        ),
        isFalse,
      );
    });

    test('A+ recipient can only receive from A+, A-, O+, O-', () {
      final validDonors = CompatibilityMatrix.getCompatibleDonorsFor('A+');
      expect(validDonors, containsAll(['A+', 'A-', 'O+', 'O-']));
      expect(validDonors.contains('B+'), isFalse);
      expect(validDonors.contains('B-'), isFalse);
      expect(validDonors.contains('AB+'), isFalse);
    });

    test('B- recipient can only receive from B- and O-', () {
      final validDonors = CompatibilityMatrix.getCompatibleDonorsFor('B-');
      expect(validDonors, containsAll(['B-', 'O-']));
      expect(validDonors.contains('B+'), isFalse);
      expect(validDonors.contains('O+'), isFalse);
    });

    test('canDonateTo calculates correct recipients', () {
      final oMinusReceivers = CompatibilityMatrix.canDonateTo('O-');
      expect(oMinusReceivers.length, equals(8)); // All 8 groups

      final abPlusReceivers = CompatibilityMatrix.canDonateTo('AB+');
      expect(abPlusReceivers, equals(['AB+'])); // Only AB+
    });
  });
}
