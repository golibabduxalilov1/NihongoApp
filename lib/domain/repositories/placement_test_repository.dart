import '../entities/placement_test.dart';

abstract class PlacementTestRepository {
  /// Qiyinlik darajasi bo'yicha tartiblangan savollar (oson -> qiyin).
  Future<List<PlacementTestQuestion>> getQuestions({int limit = 15});
  Future<void> saveResult(PlacementTestResult result);
}
