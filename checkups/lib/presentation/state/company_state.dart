import '../../domain/entities/company.dart';

class CompanyState {
  final List<Company> companies;
  final bool isLoading;
  final String? error;
  final Company? selectedCompany;

  const CompanyState({
    this.companies = const [],
    this.isLoading = false,
    this.error,
    this.selectedCompany,
  });

  CompanyState copyWith({
    List<Company>? companies,
    bool? isLoading,
    String? error,
    Company? selectedCompany,
  }) {
    return CompanyState(
      companies: companies ?? this.companies,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      selectedCompany: selectedCompany ?? this.selectedCompany,
    );
  }
}
