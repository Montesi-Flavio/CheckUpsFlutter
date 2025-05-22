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
}
