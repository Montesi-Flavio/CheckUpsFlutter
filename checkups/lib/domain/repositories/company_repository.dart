import 'package:isar/isar.dart';
import 'package:checkups/domain/entities/index.dart';
import 'base_repository.dart';

abstract class CompanyRepository extends BaseRepository<Company> {
  Future<List<Company>> searchByName(String name);
  Future<List<Company>> getByFiscalCode(String fiscalCode);
  Future<List<Company>> getByVatNumber(String vatNumber);
}
