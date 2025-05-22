import '../entities/index.dart';
import 'base_repository.dart';

abstract class TitleRepository extends BaseRepository<Title> {
  Future<List<Title>> getByDepartmentId(int departmentId);
  Future<List<Title>> searchByName(String name);
}
