/// Donor-specific profile with gamification and eligibility fields
class DonorProfileModel {
  final String donorId;
  final bool availability;
  final DateTime? lastDonationDate;
  final bool isEligible;
  final int points;
  final List<String> badges;
  final int totalDonations;
  final int livesSaved;
  final double latitude;
  final double longitude;
  final Map<String, dynamic>? healthChecklist;

  DonorProfileModel({
    required this.donorId,
    this.availability = true,
    this.lastDonationDate,
    this.isEligible = true,
    this.points = 250,
    this.badges = const ['First Drop 🩸', 'Verified Donor 🛡️'],
    this.totalDonations = 2,
    this.livesSaved = 6,
    this.latitude = 18.5204,
    this.longitude = 73.8567,
    this.healthChecklist,
  });

  factory DonorProfileModel.fromMap(Map<String, dynamic> map, String id) {
    return DonorProfileModel(
      donorId: id,
      availability: map['availability'] ?? true,
      lastDonationDate: map['lastDonationDate'] != null
          ? DateTime.tryParse(map['lastDonationDate'])
          : null,
      isEligible: map['isEligible'] ?? true,
      points: map['points'] ?? 0,
      badges: List<String>.from(map['badges'] ?? []),
      totalDonations: map['totalDonations'] ?? 0,
      livesSaved: map['livesSaved'] ?? 0,
      latitude: (map['latitude'] as num?)?.toDouble() ?? 18.5204,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 73.8567,
      healthChecklist: map['healthChecklist'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'donorId': donorId,
      'availability': availability,
      'lastDonationDate': lastDonationDate?.toIso8601String(),
      'isEligible': isEligible,
      'points': points,
      'badges': badges,
      'totalDonations': totalDonations,
      'livesSaved': livesSaved,
      'latitude': latitude,
      'longitude': longitude,
      'healthChecklist': healthChecklist,
    };
  }

  DonorProfileModel copyWith({
    bool? availability,
    DateTime? lastDonationDate,
    bool? isEligible,
    int? points,
    List<String>? badges,
    int? totalDonations,
    int? livesSaved,
    double? latitude,
    double? longitude,
    Map<String, dynamic>? healthChecklist,
  }) {
    return DonorProfileModel(
      donorId: donorId,
      availability: availability ?? this.availability,
      lastDonationDate: lastDonationDate ?? this.lastDonationDate,
      isEligible: isEligible ?? this.isEligible,
      points: points ?? this.points,
      badges: badges ?? this.badges,
      totalDonations: totalDonations ?? this.totalDonations,
      livesSaved: livesSaved ?? this.livesSaved,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      healthChecklist: healthChecklist ?? this.healthChecklist,
    );
  }
}
