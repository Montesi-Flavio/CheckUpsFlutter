import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/local_unit_repository_impl.dart';
import '../../domain/entities/local_unit.dart';
import '../../data/datasources/database_helper.dart';
import 'local_unit_state.dart';

final localUnitStateProvider = StateNotifierProvider<LocalUnitNotifier, LocalUnitState>((ref) {
  final repository = ref.watch(localUnitRepositoryProvider);
  return LocalUnitNotifier(repository);
});

final localUnitRepositoryProvider = Provider((ref) {
  final db = DatabaseHelper();
  return LocalUnitRepositoryImpl(db);
});

class LocalUnitNotifier extends StateNotifier<LocalUnitState> {
  final LocalUnitRepositoryImpl _repository;

  LocalUnitNotifier(this._repository) : super(const LocalUnitState());

  Future<void> loadLocalUnits({int? companyId}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final localUnits = companyId != null ? await _repository.getByCompanyId(companyId) : await _repository.getAll();
      state = state.copyWith(
        localUnits: localUnits,
        isLoading: false,
        selectedCompanyId: companyId,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Errore nel caricamento delle unità locali: ${e.toString()}',
      );
    }
  }

  Future<void> addLocalUnit(LocalUnit localUnit) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.insert(localUnit);
      await loadLocalUnits(companyId: state.selectedCompanyId);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Errore nell\'aggiunta dell\'unità locale: ${e.toString()}',
      );
    }
  }

  Future<void> updateLocalUnit(LocalUnit localUnit) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.update(localUnit);
      await loadLocalUnits(companyId: state.selectedCompanyId);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Errore nell\'aggiornamento dell\'unità locale: ${e.toString()}',
      );
    }
  }

  Future<void> deleteLocalUnit(int id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.delete(id);
      await loadLocalUnits(companyId: state.selectedCompanyId);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Errore nella cancellazione dell\'unità locale: ${e.toString()}',
      );
    }
  }

  void selectLocalUnit(LocalUnit? localUnit) {
    state = state.copyWith(selectedLocalUnit: localUnit);
  }

  Future<void> searchLocalUnits(String query) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final localUnits = await _repository.searchByName(query);
      state = state.copyWith(
        localUnits: localUnits,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Errore nella ricerca delle unità locali: ${e.toString()}',
      );
    }
  }
}
