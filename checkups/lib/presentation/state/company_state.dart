import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/company.dart';

part 'company_state.freezed.dart';

@freezed
class CompanyState with _$CompanyState {
  const factory CompanyState({
    @Default([]) List<Company> companies,
    @Default(false) bool isLoading,
    @Default(null) String? error,
    @Default(null) Company? selectedCompany,
  }) = _CompanyState;
}
