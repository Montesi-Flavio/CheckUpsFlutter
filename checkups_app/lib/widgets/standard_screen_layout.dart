import 'package:flutter/material.dart';
import 'shared_header.dart';
import 'context_header.dart';
import '../models/societa.dart';
import '../models/unita_locale.dart';
import '../models/reparto.dart';
import '../models/titolo.dart';
import '../models/oggetto.dart';
import 'modern_action_button.dart';

class StandardScreenLayout extends StatelessWidget {
  final String title;
  final Widget child;
  final Societa? societa;
  final UnitaLocale? unitaLocale;
  final Reparto? reparto;
  final Titolo? titolo;
  final Oggetto? oggetto;
  final VoidCallback? onBack;
  final VoidCallback? onAdd;
  final VoidCallback? onImport;
  final VoidCallback? onDelete;
  final VoidCallback? onNext; // Optional next step action

  const StandardScreenLayout({
    super.key,
    required this.title,
    required this.child,
    this.societa,
    this.unitaLocale,
    this.reparto,
    this.titolo,
    this.oggetto,
    this.onBack,
    this.onAdd,
    this.onImport,
    this.onDelete,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 1. Shared Header
          SharedHeader(isHomeActive: false, onHomePressed: () => Navigator.of(context).popUntil((route) => route.isFirst), isAdminActive: true),

          // 2. Context Header
          ContextHeader(societa: societa, unitaLocale: unitaLocale, reparto: reparto, titolo: titolo, oggetto: oggetto),

          // 3. Main Content Area
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                // Title
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Toolbar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      if (onBack != null) ...[ModernActionButton(icon: Icons.arrow_back_ios_new, onPressed: onBack!, tooltip: 'Indietro')],
                      const Spacer(),
                      if (onAdd != null) ...[
                        ModernActionButton(icon: Icons.add, label: 'Aggiungi', isPrimary: true, onPressed: onAdd!),
                        const SizedBox(width: 8),
                      ],
                      if (onImport != null) ...[ModernActionButton(icon: Icons.download, label: 'Importa', onPressed: onImport!), const SizedBox(width: 8)],
                      if (onNext != null) ...[ModernActionButton(icon: Icons.arrow_forward_ios, onPressed: onNext!, tooltip: 'Avanti')],
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Content (List/Table header + body)
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
