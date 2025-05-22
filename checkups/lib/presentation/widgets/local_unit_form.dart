import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import '../../domain/entities/local_unit.dart';
import '../state/local_unit_provider.dart';

class LocalUnitForm extends ConsumerStatefulWidget {
  final LocalUnit? localUnit;
  final int companyId;

  const LocalUnitForm({
    super.key,
    this.localUnit,
    required this.companyId,
  });

  @override
  ConsumerState<LocalUnitForm> createState() => _LocalUnitFormState();
}

class _LocalUnitFormState extends ConsumerState<LocalUnitForm> {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return FormBuilder(
      key: _formKey,
      initialValue: widget.localUnit != null
          ? {
              'name': widget.localUnit!.name,
              'address': widget.localUnit!.address ?? '',
              'city': widget.localUnit!.city ?? '',
              'province': widget.localUnit!.province ?? '',
              'postalCode': widget.localUnit!.postalCode ?? '',
              'country': widget.localUnit!.country ?? '',
              'phone': widget.localUnit!.phone ?? '',
              'email': widget.localUnit!.email ?? '',
              'notes': widget.localUnit!.notes ?? '',
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
            name: 'address',
            decoration: const InputDecoration(labelText: 'Indirizzo'),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FormBuilderTextField(
                  name: 'city',
                  decoration: const InputDecoration(labelText: 'Città'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FormBuilderTextField(
                  name: 'province',
                  decoration: const InputDecoration(labelText: 'Provincia'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FormBuilderTextField(
                  name: 'postalCode',
                  decoration: const InputDecoration(labelText: 'CAP'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FormBuilderTextField(
                  name: 'country',
                  decoration: const InputDecoration(labelText: 'Paese'),
                  initialValue: 'Italia',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FormBuilderTextField(
            name: 'phone',
            decoration: const InputDecoration(labelText: 'Telefono'),
          ),
          const SizedBox(height: 16),
          FormBuilderTextField(
            name: 'email',
            decoration: const InputDecoration(labelText: 'Email'),
            validator: FormBuilderValidators.email(),
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
                child: Text(widget.localUnit != null ? 'SALVA' : 'CREA'),
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
      final localUnit = LocalUnit(
        id: widget.localUnit?.id ?? 0,
        name: data['name'],
        companyId: widget.companyId,
        address: data['address'],
        city: data['city'],
        province: data['province'],
        postalCode: data['postalCode'],
        country: data['country'],
        phone: data['phone'],
        email: data['email'],
        notes: data['notes'],
      );

      if (widget.localUnit != null) {
        ref.read(localUnitStateProvider.notifier).updateLocalUnit(localUnit);
      } else {
        ref.read(localUnitStateProvider.notifier).addLocalUnit(localUnit);
      }

      Navigator.pop(context);
    }
  }
}
