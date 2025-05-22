import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:isar/isar.dart';
import '../../domain/entities/index.dart';
import '../state/department_provider.dart';

class DepartmentForm extends ConsumerWidget {
  final Department? department;
  final int localUnitId;

  const DepartmentForm({
    super.key,
    this.department,
    required this.localUnitId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormBuilderState>();

    return FormBuilder(
      key: formKey,
      initialValue: department != null
          ? {
              'name': department!.name,
              'description': department!.description ?? '',
              'notes': department!.notes ?? '',
            }
          : {},
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FormBuilderTextField(
            name: 'name',
            decoration: const InputDecoration(labelText: 'Nome*'),
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(),
            ]),
          ),
          const SizedBox(height: 16),
          FormBuilderTextField(
            name: 'description',
            decoration: const InputDecoration(labelText: 'Descrizione'),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          FormBuilderTextField(
            name: 'notes',
            decoration: const InputDecoration(labelText: 'Note'),
            maxLines: 3,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('ANNULLA'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState?.saveAndValidate() ?? false) {
                    final data = formKey.currentState!.value;
                    final department = Department(
                      id: this.department?.id ?? Isar.autoIncrement,
                      name: data['name'],
                      localUnitId: localUnitId,
                      description: data['description'],
                      notes: data['notes'],
                    );

                    if (this.department != null) {
                      ref.read(departmentStateProvider.notifier).updateDepartment(department);
                    } else {
                      ref.read(departmentStateProvider.notifier).addDepartment(department);
                    }

                    Navigator.pop(context);
                  }
                },
                child: Text(department != null ? 'SALVA' : 'CREA'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
