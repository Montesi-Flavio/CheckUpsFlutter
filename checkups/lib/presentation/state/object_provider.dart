import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/checkup_item.dart';
import 'object_state.dart';

class ObjectNotifier extends StateNotifier<ObjectState> {
  ObjectNotifier() : super(const ObjectState());

  Future<void> loadObjects({required int titleId}) async {
    state = state.copyWith(isLoading: true, error: null, selectedTitleId: titleId);
    try {
      // TODO: Carica gli oggetti dal repository/database
      final List<CheckupItem> objects = [];
      state = state.copyWith(objects: objects, isLoading: false, error: null);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // TODO: implementare metodi CRUD (add, update, delete)
}

final objectStateProvider = StateNotifierProvider<ObjectNotifier, ObjectState>((ref) {
  return ObjectNotifier();
});
