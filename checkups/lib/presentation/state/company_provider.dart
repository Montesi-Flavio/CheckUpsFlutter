import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/company_repository_impl.dart';
import '../../domain/entities/index.dart';
import 'company_state.dart';
import 'database_provider.dart';

final companyStateProvider = StateNotifierProvider<CompanyNotifier, CompanyState>((ref) {
  final repository = ref.watch(companyRepositoryProvider);
  return CompanyNotifier(repository);
});

final companyRepositoryProvider = Provider((ref) {
  final db = ref.watch(databaseProvider);
  return CompanyRepositoryImpl(db);
});

class CompanyNotifier extends StateNotifier<CompanyState> {
  final CompanyRepositoryImpl _repository;

  CompanyNotifier(this._repository) : super(const CompanyState()) {
    loadCompanies();
  }

  Future<void> loadCompanies() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final companies = await _repository.getAll();
      state = state.copyWith(
        companies: companies,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Errore nel caricamento delle aziende: ${e.toString()}',
      );
    }
  }

  Future<void> addCompany(Company company) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.insert(company);
      await loadCompanies();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Errore nell\'aggiunta dell\'azienda: ${e.toString()}',
      );
    }
  }

  Future<void> updateCompany(Company company) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.update(company);
      await loadCompanies();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Errore nell\'aggiornamento dell\'azienda: ${e.toString()}',
      );
    }
  }

  Future<void> deleteCompany(int id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.delete(id);
      await loadCompanies();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Errore nella cancellazione dell\'azienda: ${e.toString()}',
      );
    }
  }

  void selectCompany(Company? company) {
    state = state.copyWith(selectedCompany: company);
  }

  Future<void> searchCompanies(String query) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final companies = await _repository.searchByName(query);
      state = state.copyWith(
        companies: companies,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Errore nella ricerca delle aziende: ${e.toString()}',
      );
    }
  }
}
