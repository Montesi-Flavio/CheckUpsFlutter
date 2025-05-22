import '../../domain/entities/checkup_item.dart';

class ObjectState {
  final List<CheckupItem> objects;
  final bool isLoading;
  final String? error;
  final int? selectedTitleId;

  const ObjectState({
    this.objects = const [],
    this.isLoading = false,
    this.error,
    this.selectedTitleId,
  });

  ObjectState copyWith({
    List<CheckupItem>? objects,
    bool? isLoading,
    String? error,
    int? selectedTitleId,
  }) {
    return ObjectState(
      objects: objects ?? this.objects,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedTitleId: selectedTitleId ?? this.selectedTitleId,
    );
  }

  @override
  List<Object?> get props => [objects, isLoading, error, selectedTitleId];
}
