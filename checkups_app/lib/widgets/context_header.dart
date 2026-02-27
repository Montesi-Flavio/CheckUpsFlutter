import 'package:flutter/material.dart';
import '../models/societa.dart';
import '../models/unita_locale.dart';
import '../models/reparto.dart';
import '../models/titolo.dart';
import '../models/oggetto.dart';

class ContextHeader extends StatelessWidget {
  final Societa? societa;
  final UnitaLocale? unitaLocale;
  final Reparto? reparto;
  final Titolo? titolo;
  final Oggetto? oggetto;

  const ContextHeader({
    super.key,
    this.societa,
    this.unitaLocale,
    this.reparto,
    this.titolo,
    this.oggetto,
  });

  @override
  Widget build(BuildContext context) {
    if (societa == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      color: Colors.grey[200],
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Wrap(
        spacing: 16,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: [
          _buildPill('Società', societa!.nome),
          if (unitaLocale != null)
            _buildPill('Unità Locale', unitaLocale!.nome),
          if (reparto != null) _buildPill('Reparto', reparto!.nome),
          if (titolo != null)
            _buildPill('Titolo', titolo!.descrizione), // Might need truncation
          if (oggetto != null) _buildPill('Oggetto', oggetto!.nome),
        ],
      ),
    );
  }

  Widget _buildPill(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: Colors.black54),
          ),
          Text(
            value.length > 30 ? '${value.substring(0, 30)}...' : value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
