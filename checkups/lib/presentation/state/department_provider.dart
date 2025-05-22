import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/department_repository_impl.dart';
import '../../domain/entities/index.dart';
import 'department_state.dart';

final departmentStateProvider = StateNotifierProvider<DepartmentNotifier, DepartmentState>((ref) {
  final repository = ref.watch(departmentRepositoryProvider);
  return DepartmentNotifier(repository);
});

final departmentRepositoryProvider = Provider((ref) {
  final isar = ref.watch(isarProvider);
  return DepartmentRepositoryImpl(isar);
});

class DepartmentNotifier extends StateNotifier<DepartmentState> {
  final DepartmentRepositoryImpl _repository;

  DepartmentNotifier(this._repository) : super(const DepartmentState());

  Future<void> loadDepartments({int? localUnitId}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final departments = localUnitId != null ? await _repository.getByLocalUnitId(localUnitId) : await _repository.getAll();
      state = state.copyWith(
        departments: departments,
        isLoading: false,
        selectedLocalUnitId: localUnitId,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Errore nel caricamento dei reparti: ${e.toString()}',
      );
    }
  }

  Future<void> addDepartment(Department department) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.insert(department);
      await loadDepartments(localUnitId: state.selectedLocalUnitId);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Errore nell\'aggiunta del reparto: ${e.toString()}',
      );
    }
  }

  Future<void> updateDepartment(Department department) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.update(department);
      await loadDepartments(localUnitId: state.selectedLocalUnitId);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Errore nell\'aggiornamento del reparto: ${e.toString()}',
      );
    }
  }

  Future<void> deleteDepartment(int id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.delete(id);
      await loadDepartments(localUnitId: state.selectedLocalUnitId);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Errore nella cancellazione del reparto: ${e.toString()}',
      );
    }
  }

  void selectDepartment(Department? department) {
    state = state.copyWith(selectedDepartment: department);
  }

  Future<void> searchDepartments(String query) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final departments = await _repository.searchByName(query);
      state = state.copyWith(
        departments: departments,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Errore nella ricerca dei reparti: ${e.toString()}',
      );
    }
  }
}
