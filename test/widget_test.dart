import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_blood_link/widgets/blood_group_chip.dart';
import 'package:smart_blood_link/widgets/status_badge.dart';

void main() {
  group('Smart BloodLink Widget Tests', () {
    testWidgets('BloodGroupChip renders label and triggers tap callback', (tester) async {
      bool wasTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: BloodGroupChip(
                bloodGroup: 'O+',
                isSelected: false,
                onTap: () {
                  wasTapped = true;
                },
              ),
            ),
          ),
        ),
      );

      // Verify label is displayed
      expect(find.text('O+'), findsOneWidget);

      // Tap on the chip
      await tester.tap(find.text('O+'));
      await tester.pumpAndSettle();

      expect(wasTapped, isTrue);
    });

    testWidgets('StatusBadge displays correct text and renders without errors', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: StatusBadge(
                label: 'Verified Donor',
                color: Colors.green,
                icon: Icons.check_circle,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Verified Donor'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });
  });
}
