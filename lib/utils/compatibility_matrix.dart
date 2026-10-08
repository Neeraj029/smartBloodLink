/// Clinical Red Blood Cell Compatibility Matrix for Transfusions
class CompatibilityMatrix {
  CompatibilityMatrix._();

  static const Map<String, List<String>> _compatibleDonors = {
    'A+': ['A+', 'A-', 'O+', 'O-'],
    'A-': ['A-', 'O-'],
    'B+': ['B+', 'B-', 'O+', 'O-'],
    'B-': ['B-', 'O-'],
    'AB+': ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'], // Universal Recipient
    'AB-': ['AB-', 'A-', 'B-', 'O-'],
    'O+': ['O+', 'O-'],
    'O-': ['O-'], // Can only receive from O-
  };

  /// Returns true if donor blood is compatible with recipient blood
  static bool isCompatible({
    required String donorGroup,
    required String recipientGroup,
  }) {
    final validDonors = _compatibleDonors[recipientGroup];
    if (validDonors == null) return false;
    return validDonors.contains(donorGroup);
  }

  /// Returns all compatible donor groups for a given patient recipient group
  static List<String> getCompatibleDonorsFor(String recipientGroup) {
    return _compatibleDonors[recipientGroup] ?? [recipientGroup];
  }

  /// Returns who this blood group can donate to
  static List<String> canDonateTo(String donorGroup) {
    final results = <String>[];
    for (final entry in _compatibleDonors.entries) {
      if (entry.value.contains(donorGroup)) {
        results.add(entry.key);
      }
    }
    return results;
  }
}
