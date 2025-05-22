import '../entities/index.dart';
import 'base_repository.dart';

abstract class DepartmentRepository extends BaseRepository<Department> {
  Future<List<Department>> getByLocalUnitId(int localUnitId);
  Future<List<Department>> searchByName(String name);
}
