import 'package:flutter/material.dart' hide Title;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import '../../domain/entities/index.dart';
import '../state/title_provider.dart';

class TitleForm extends ConsumerStatefulWidget {
  final Title? title;
  final int departmentId;

  const TitleForm({
    super.key,
    this.title,
    required this.departmentId,
  });

  @override
  ConsumerState<TitleForm> createState() => _TitleFormState();
}

class _TitleFormState extends ConsumerState<TitleForm> {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return FormBuilder(
      key: _formKey,
      initialValue: widget.title != null
          ? {
              'name': widget.title!.name,
              'description': widget.title!.description ?? '',
              'notes': widget.title!.notes ?? '',
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
                onPressed: _submitForm,
                child: Text(widget.title != null ? 'SALVA' : 'CREA'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final data = _formKey.currentState!.value;
      final title = Title(
        id: widget.title?.id ?? 0,
        name: data['name'],
        departmentId: widget.departmentId,
        description: data['description'],
        notes: data['notes'],
      );

      if (widget.title != null) {
        ref.read(titleStateProvider.notifier).updateTitle(title);
      } else {
        ref.read(titleStateProvider.notifier).addTitle(title);
      }

      Navigator.pop(context);
    }
  }
}
