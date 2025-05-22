import 'package:flutter/foundation.dart';
import '../../domain/entities/local_unit.dart';

@immutable
class LocalUnitState {
  final List<LocalUnit> localUnits;
  final bool isLoading;
  final String? error;
  final LocalUnit? selectedLocalUnit;
  final int? selectedCompanyId;

  const LocalUnitState({
    this.localUnits = const [],
    this.isLoading = false,
    this.error,
    this.selectedLocalUnit,
    this.selectedCompanyId,
  });

  LocalUnitState copyWith({
    List<LocalUnit>? localUnits,
    bool? isLoading,
    String? error,
    LocalUnit? selectedLocalUnit,
    int? selectedCompanyId,
  }) {
    return LocalUnitState(
      localUnits: localUnits ?? this.localUnits,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      selectedLocalUnit: selectedLocalUnit ?? this.selectedLocalUnit,
      selectedCompanyId: selectedCompanyId ?? this.selectedCompanyId,
    );
  }
}
