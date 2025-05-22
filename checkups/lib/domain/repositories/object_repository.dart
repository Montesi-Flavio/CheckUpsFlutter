import '../entities/checkup_item.dart';
import 'base_repository.dart';

abstract class ObjectRepository extends BaseRepository<CheckupItem> {
  Future<List<CheckupItem>> findByTitleId(int titleId);
}
