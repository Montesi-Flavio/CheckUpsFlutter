import '../entities/object.dart';
import 'base_repository.dart';

abstract class ObjectRepository extends BaseRepository<Object> {
  Future<List<Object>> findByTitleId(int titleId);
}
