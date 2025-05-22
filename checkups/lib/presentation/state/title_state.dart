import 'package:flutter/foundation.dart';
import '../../domain/entities/index.dart';

@immutable
class TitleState {
  final List<Title> titles;
  final bool isLoading;
  final String? error;
  final Title? selectedTitle;
  final int? selectedDepartmentId;

  const TitleState({
    this.titles = const [],
    this.isLoading = false,
    this.error,
    this.selectedTitle,
    this.selectedDepartmentId,
  });
}
