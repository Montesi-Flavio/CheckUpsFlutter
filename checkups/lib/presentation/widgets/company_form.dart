import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import '../../domain/entities/index.dart';
import '../state/company_provider.dart';

class CompanyForm extends ConsumerStatefulWidget {
  final Company? company;

  const CompanyForm({super.key, this.company});

  @override
  ConsumerState<CompanyForm> createState() => _CompanyFormState();
}

class _CompanyFormState extends ConsumerState<CompanyForm> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return FormBuilder(
      key: _formKey,
      initialValue: widget.company != null
          ? {
              'name': widget.company!.name,
              'fiscalCode': widget.company!.fiscalCode,
              'vatNumber': widget.company!.vatNumber,
              'address': widget.company!.address ?? '',
              'city': widget.company!.city ?? '',
              'province': widget.company!.province ?? '',
              'postalCode': widget.company!.postalCode ?? '',
              'country': widget.company!.country ?? '',
              'phone': widget.company!.phone ?? '',
              'email': widget.company!.email ?? '',
              'pec': widget.company!.pec ?? '',
              'notes': widget.company!.notes ?? '',
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
            name: 'fiscalCode',
            decoration: const InputDecoration(labelText: 'Codice Fiscale*'),
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(),
            ]),
          ),
          const SizedBox(height: 16),
          FormBuilderTextField(
            name: 'vatNumber',
            decoration: const InputDecoration(labelText: 'Partita IVA*'),
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
            name: 'pec',
            decoration: const InputDecoration(labelText: 'PEC'),
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
                onPressed: _isLoading ? null : _submitForm,
                child: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(widget.company != null ? 'SALVA' : 'CREA'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _submitForm() async {
    if (!(_formKey.currentState?.saveAndValidate() ?? false)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fix the errors before submitting')));
      return;
    }

    setState(() => _isLoading = true);
    final data = _formKey.currentState!.value;
    final company = Company(
      id: widget.company?.id ?? 0,
      name: data['name'],
      fiscalCode: data['fiscalCode'],
      vatNumber: data['vatNumber'],
      address: data['address'],
      city: data['city'],
      province: data['province'],
      postalCode: data['postalCode'],
      country: data['country'],
      phone: data['phone'],
      email: data['email'],
      pec: data['pec'],
      notes: data['notes'],
    );

    try {
      if (widget.company != null) {
        await ref.read(companyStateProvider.notifier).updateCompany(company);
      } else {
        await ref.read(companyStateProvider.notifier).addCompany(company);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
