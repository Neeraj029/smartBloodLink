/// Donor achievement badge model
class DonorBadgeModel {
  final String id;
  final String title;
  final String description;
  final String iconEmoji;
  final int requiredDonations;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  DonorBadgeModel({
    required this.id,
    required this.title,
    required this.description,
    required this.iconEmoji,
    required this.requiredDonations,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  DonorBadgeModel copyWith({bool? isUnlocked, DateTime? unlockedAt}) {
    return DonorBadgeModel(
      id: id,
      title: title,
      description: description,
      iconEmoji: iconEmoji,
      requiredDonations: requiredDonations,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }
}
