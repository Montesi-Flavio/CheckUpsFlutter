import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/local_unit.dart';

part 'local_unit_state.freezed.dart';

@freezed
class LocalUnitState with _$LocalUnitState {
  const factory LocalUnitState({
    @Default([]) List<LocalUnit> localUnits,
    @Default(false) bool isLoading,
    @Default(null) String? error,
    @Default(null) LocalUnit? selectedLocalUnit,
    @Default(null) int? selectedCompanyId,
  }) = _LocalUnitState;
}
