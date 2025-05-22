import '../entities/index.dart';
import 'base_repository.dart';

abstract class LocalUnitRepository extends BaseRepository<LocalUnit> {
  Future<List<LocalUnit>> getByCompanyId(int companyId);
  Future<List<LocalUnit>> searchByName(String name);
}
