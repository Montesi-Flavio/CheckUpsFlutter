import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/title_repository_impl.dart';
import '../../domain/entities/title.dart';
import '../../data/datasources/database_helper.dart';
import 'title_state.dart';

final titleStateProvider = StateNotifierProvider<TitleNotifier, TitleState>((ref) {
  final repository = ref.watch(titleRepositoryProvider);
  return TitleNotifier(repository);
});

final titleRepositoryProvider = Provider((ref) {
  final db = DatabaseHelper();
  return TitleRepositoryImpl(db);
});

class TitleNotifier extends StateNotifier<TitleState> {
  final TitleRepositoryImpl _repository;

  TitleNotifier(this._repository) : super(const TitleState());

  Future<void> loadTitles({int? departmentId}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final titles = departmentId != null ? await _repository.getByDepartmentId(departmentId) : await _repository.getAll();
      state = state.copyWith(
        titles: titles,
        isLoading: false,
        selectedDepartmentId: departmentId,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Errore nel caricamento dei titoli: ${e.toString()}',
      );
    }
  }

  Future<void> addTitle(Title title) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.insert(title);
      await loadTitles(departmentId: state.selectedDepartmentId);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Errore nell\'aggiunta del titolo: ${e.toString()}',
      );
    }
  }

  Future<void> updateTitle(Title title) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.update(title);
      await loadTitles(departmentId: state.selectedDepartmentId);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Errore nell\'aggiornamento del titolo: ${e.toString()}',
      );
    }
  }

  Future<void> deleteTitle(int id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.delete(id);
      await loadTitles(departmentId: state.selectedDepartmentId);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Errore nella cancellazione del titolo: ${e.toString()}',
      );
    }
  }

  void selectTitle(Title? title) {
    state = state.copyWith(selectedTitle: title);
  }

  Future<void> searchTitles(String query) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final titles = await _repository.searchByName(query);
      state = state.copyWith(
        titles: titles,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Errore nella ricerca dei titoli: ${e.toString()}',
      );
    }
  }
}
