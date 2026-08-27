import '../entities/mistake_log_entry.dart';
import '../repositories/mistake_repository.dart';

/// Foydalanuvchining eng ko'p xato qilgan mavzularini (masalan は/が/を
/// zarrachalari) topadi. Statistika ekranida "Zaif tomonlar" bo'limi
/// va Practice Hub'dagi "shu mavzuni mashq qiling" tavsiyasi shu orqali ishlaydi.
class GetWeakPointsUseCase {
  final MistakeRepository repository;
  GetWeakPointsUseCase(this.repository);

  Future<List<WeakPoint>> call({int limit = 10}) {
    return repository.getWeakPoints(limit: limit);
  }
}
