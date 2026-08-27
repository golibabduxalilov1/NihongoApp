import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user_stats.dart';
import '../../domain/entities/mistake_log_entry.dart';
import 'repository_providers.dart';

final userStatsProvider = FutureProvider<UserStats>((ref) async {
  final repo = ref.watch(userStatsRepositoryProvider);
  return repo.getStats();
});

final weakPointsProvider = FutureProvider<List<WeakPoint>>((ref) async {
  final useCase = ref.watch(getWeakPointsUseCaseProvider);
  return useCase.call();
});
