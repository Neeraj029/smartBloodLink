import '../models/donor_profile_model.dart';
import '../models/badge_model.dart';
import '../services/mock_data_service.dart';

/// Repository for donor profile, gamification points, and leaderboards
class DonorRepository {
  DonorProfileModel get donorProfile => MockDataService.initialDonorProfile;

  List<DonorBadgeModel> get allBadges =>
      List.unmodifiable(MockDataService.allBadges);

  List<Map<String, dynamic>> get leaderboard =>
      List.unmodifiable(MockDataService.leaderboard);

  Future<void> toggleAvailability(bool isAvailable) async {
    MockDataService.initialDonorProfile =
        MockDataService.initialDonorProfile.copyWith(availability: isAvailable);
  }

  Future<void> addPoints(int pointsToAdd) async {
    final newPoints = MockDataService.initialDonorProfile.points + pointsToAdd;
    MockDataService.initialDonorProfile =
        MockDataService.initialDonorProfile.copyWith(points: newPoints);
  }
}
