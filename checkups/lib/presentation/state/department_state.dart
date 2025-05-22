import 'package:flutter/foundation.dart';
import '../../domain/entities/index.dart';

@immutable
class DepartmentState {
  final List<Department> departments;
  final bool isLoading;
  final String? error;
  final Department? selectedDepartment;
  final int? selectedLocalUnitId;

  const DepartmentState({
    this.departments = const [],
    this.isLoading = false,
    this.error,
    this.selectedDepartment,
    this.selectedLocalUnitId,
  });

  DepartmentState copyWith({
    List<Department>? departments,
    bool? isLoading,
    String? error,
    Department? selectedDepartment,
    int? selectedLocalUnitId,
  }) {
    return DepartmentState(
      departments: departments ?? this.departments,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      selectedDepartment: selectedDepartment ?? this.selectedDepartment,
      selectedLocalUnitId: selectedLocalUnitId ?? this.selectedLocalUnitId,
    );
  }
}
