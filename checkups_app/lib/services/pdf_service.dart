import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import '../models/societa.dart';
import '../models/unita_locale.dart';
import '../models/reparto.dart';
import '../models/provvedimento.dart';
import '../repositories/database_repository.dart';

class PdfService {
  final DatabaseRepository _repository;

  PdfService(this._repository);

  /// Genera il PDF di Valutazione Rischi
  Future<Uint8List> generaValutazioneRischi({
    required Societa societa,
    required UnitaLocale unitaLocale,
    required List<Reparto> reparti,
  }) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd/MM/yyyy');

    // Carica logo CheckUps per footer
    pw.MemoryImage? checkUpsLogo;
    try {
      final logoData = await rootBundle.load('assets/LOGOCheckUp.png');
      checkUpsLogo = pw.MemoryImage(logoData.buffer.asUint8List());
    } catch (e) {
      // Logo CheckUps non disponibile
    }

    // Logo della Società per copertina
    pw.MemoryImage? societaLogo;
    if (societa.hasImage && societa.logoBytes != null) {
      societaLogo = pw.MemoryImage(societa.logoBytes!);
    }

    // Font (usa font di default del package pdf)
    final fontBold = pw.Font.helveticaBold();
    final fontRegular = pw.Font.helvetica();
    final fontItalic = pw.Font.helveticaOblique();

    // Data per footer copertina
    final dataValutazioneCopertina =
        reparti.isNotEmpty && reparti.first.data != null
        ? dateFormat.format(reparti.first.data!)
        : dateFormat.format(DateTime.now());
    final revisioneCopertina = reparti.isNotEmpty
        ? reparti.first.revisione
        : '';

    // ===================== COPERTINA =====================
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.fromLTRB(36, 36, 36, 50),
        build: (context) => pw.Stack(
          children: [
            // Contenuto principale
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                // Società e Unità Locale (con bordo sotto)
                pw.Container(
                  padding: const pw.EdgeInsets.only(bottom: 8),
                  decoration: const pw.BoxDecoration(
                    border: pw.Border(bottom: pw.BorderSide(width: 1)),
                  ),
                  child: pw.Row(
                    children: [
                      pw.Text(
                        'Società/Ente:',
                        style: pw.TextStyle(font: fontRegular, fontSize: 10),
                      ),
                      pw.SizedBox(width: 8),
                      pw.Text(
                        societa.nome,
                        style: pw.TextStyle(font: fontBold, fontSize: 10),
                      ),
                      pw.Spacer(),
                      pw.Text(
                        'Un. Produttiva:',
                        style: pw.TextStyle(font: fontRegular, fontSize: 10),
                      ),
                      pw.SizedBox(width: 8),
                      pw.Text(
                        unitaLocale.nome,
                        style: pw.TextStyle(font: fontBold, fontSize: 10),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 30),

                // Logo Società
                if (societaLogo != null)
                  pw.Center(child: pw.Image(societaLogo, height: 120))
                else if (checkUpsLogo != null)
                  pw.Center(child: pw.Image(checkUpsLogo, height: 120)),
                pw.SizedBox(height: 25),

                // Titolo
                pw.Center(
                  child: pw.Text(
                    'Relazione Tecnica di Valutazione Rischi -',
                    style: pw.TextStyle(
                      font: fontBold,
                      fontSize: 14,
                      color: PdfColors.green800,
                    ),
                  ),
                ),
                pw.Center(
                  child: pw.Text(
                    'in materia di salute e sicurezza sul lavoro D.Lgs. n. 81/2008 e s.m. e i.',
                    style: pw.TextStyle(
                      font: fontRegular,
                      fontSize: 12,
                      color: PdfColors.green800,
                    ),
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Center(
                  child: pw.Text(
                    'Firmano in data: ________________________',
                    style: pw.TextStyle(font: fontRegular, fontSize: 11),
                  ),
                ),
                pw.SizedBox(height: 25),

                // Firme (tabella 2x2 con bordi)
                pw.Table(
                  border: pw.TableBorder.all(width: 1),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(1),
                    1: const pw.FlexColumnWidth(1),
                  },
                  children: [
                    pw.TableRow(
                      children: [
                        _buildFirmaCella('Il Datore di Lavoro', fontItalic),
                        _buildFirmaCella(
                          'Il Rappresentante dei lavoratori per la\nsicurezza (RLS)',
                          fontItalic,
                        ),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        _buildFirmaCella(
                          'Il Responsabile del servizio di Prevenzione e\nProtezione',
                          fontItalic,
                        ),
                        _buildFirmaCella('Il Medico Competente', fontItalic),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            // Footer in fondo alla pagina
            pw.Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildCoverFooter(
                checkUpsLogo,
                societaLogo,
                revisioneCopertina,
                dataValutazioneCopertina,
                fontRegular,
                1,
                1,
              ),
            ),
          ],
        ),
      ),
    );

    // ===================== INDICE =====================
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(36),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Center(
              child: pw.Text(
                'INDICE dei contenuti ex D.Lgs. 81/08',
                style: pw.TextStyle(font: fontBold, fontSize: 12),
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(child: _buildIndiceColonna1(fontRegular)),
                pw.Expanded(child: _buildIndiceColonna2(fontRegular)),
                pw.Expanded(child: _buildIndiceColonna3(fontRegular)),
              ],
            ),
          ],
        ),
      ),
    );

    // ===================== PAGINE REPARTI =====================
    for (final reparto in reparti) {
      final titoli = await _repository.getTitoloList();
      final titoliReparto = titoli
          .where((t) => t.idReparto == reparto.id)
          .toList();
      titoliReparto.sort((a, b) => a.priorita.compareTo(b.priorita));

      final dataValutazione = reparto.data != null
          ? dateFormat.format(reparto.data!)
          : dateFormat.format(DateTime.now());

      for (final titolo in titoliReparto) {
        final oggetti = await _repository.getOggettoList();
        final oggettiTitolo = oggetti
            .where((o) => o.idTitolo == titolo.id)
            .toList();
        oggettiTitolo.sort((a, b) => a.priorita.compareTo(b.priorita));

        for (final oggetto in oggettiTitolo) {
          final provvedimenti = await _repository.getProvvedimentoList();
          final provvedimentiOggetto = provvedimenti
              .where((p) => p.idOggetto == oggetto.id)
              .toList();
          provvedimentiOggetto.sort((a, b) => a.priorita.compareTo(b.priorita));

          if (provvedimentiOggetto.isEmpty) continue;

          pdf.addPage(
            pw.MultiPage(
              pageFormat: PdfPageFormat.a4.landscape,
              margin: const pw.EdgeInsets.all(36),
              header: (context) => _buildHeader(
                societa,
                unitaLocale,
                reparto,
                fontRegular,
                fontBold,
              ),
              footer: (context) => _buildFooter(
                context,
                checkUpsLogo,
                reparto.revisione,
                dataValutazione,
                fontRegular,
              ),
              build: (context) => [
                // Titolo
                pw.Center(
                  child: pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: pw.BoxDecoration(border: pw.Border.all()),
                    child: pw.RichText(
                      text: pw.TextSpan(
                        children: [
                          pw.TextSpan(
                            text: 'Titolo: ',
                            style: pw.TextStyle(
                              font: fontRegular,
                              fontSize: 12,
                            ),
                          ),
                          pw.TextSpan(
                            text: titolo.descrizione,
                            style: pw.TextStyle(font: fontBold, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                pw.SizedBox(height: 10),

                // Oggetto
                pw.Text(
                  'Oggetto: ${oggetto.nome}',
                  style: pw.TextStyle(font: fontRegular, fontSize: 13),
                ),
                pw.SizedBox(height: 10),

                // Tabella provvedimenti
                _buildProvvedimentiTable(
                  provvedimentiOggetto,
                  fontRegular,
                  fontBold,
                  dateFormat,
                ),
              ],
            ),
          );
        }
      }
    }

    return pdf.save();
  }

  pw.Widget _buildFirmaCella(String label, pw.Font font) {
    return pw.Container(
      height: 80,
      padding: const pw.EdgeInsets.all(8),
      child: pw.Align(
        alignment: pw.Alignment.topCenter,
        child: pw.Text(
          label,
          style: pw.TextStyle(font: font, fontSize: 10),
          textAlign: pw.TextAlign.center,
        ),
      ),
    );
  }

  pw.Widget _buildCoverFooter(
    pw.MemoryImage? checkUpsLogo,
    pw.MemoryImage? societaLogo,
    String revisione,
    String dataValutazione,
    pw.Font font,
    int page,
    int totalPages,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(width: 0.5, color: PdfColors.grey400),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Row(
            children: [
              pw.Text(
                'Redatto a cura di: ',
                style: pw.TextStyle(font: font, fontSize: 9),
              ),
              if (checkUpsLogo != null) pw.Image(checkUpsLogo, height: 25),
            ],
          ),
          if (societaLogo != null) pw.Image(societaLogo, height: 30),
          pw.Text(
            'Rev N. $revisione del: $dataValutazione - Pag. $page di $totalPages',
            style: pw.TextStyle(font: font, fontSize: 9),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildIndiceColonna1(pw.Font font) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          '1. Titolo I - Gestione della prevenzione',
          style: pw.TextStyle(font: font, fontSize: 9),
        ),
        pw.Text(
          '   a. Servizio di Prevenzione e Protezione',
          style: pw.TextStyle(font: font, fontSize: 9),
        ),
        pw.Text(
          '   b. Formazione, addestramento',
          style: pw.TextStyle(font: font, fontSize: 9),
        ),
        pw.Text(
          '   c. Procedure di sicurezza',
          style: pw.TextStyle(font: font, fontSize: 9),
        ),
        pw.Text(
          '   d. Prevenzione incendi',
          style: pw.TextStyle(font: font, fontSize: 9),
        ),
        pw.Text(
          '   e. Gestione Emergenze',
          style: pw.TextStyle(font: font, fontSize: 9),
        ),
        pw.Text(
          '   f. Primo Soccorso',
          style: pw.TextStyle(font: font, fontSize: 9),
        ),
        pw.Text(
          '   g. Sorveglianza Sanitaria',
          style: pw.TextStyle(font: font, fontSize: 9),
        ),
        pw.Text(
          '   h. Rischi psico sociali',
          style: pw.TextStyle(font: font, fontSize: 9),
        ),
        pw.Text(
          '   i. Lavori in appalto interni',
          style: pw.TextStyle(font: font, fontSize: 9),
        ),
        pw.Text(
          '   j. Tutela della maternità',
          style: pw.TextStyle(font: font, fontSize: 9),
        ),
        pw.SizedBox(height: 10),
        pw.Text(
          '2. Titolo II - Luoghi di lavoro',
          style: pw.TextStyle(font: font, fontSize: 9),
        ),
        pw.Text(
          '   a. Locali di lavoro',
          style: pw.TextStyle(font: font, fontSize: 9),
        ),
        pw.Text(
          '   b. Igiene del lavoro; microclima',
          style: pw.TextStyle(font: font, fontSize: 9),
        ),
        pw.Text(
          '   c. Lavori in quota',
          style: pw.TextStyle(font: font, fontSize: 9),
        ),
        pw.Text(
          '   d. Soppalchi',
          style: pw.TextStyle(font: font, fontSize: 9),
        ),
        pw.Text(
          '   e. Ambienti confinati',
          style: pw.TextStyle(font: font, fontSize: 9),
        ),
        pw.Text(
          '   f. Vie di Circolazione',
          style: pw.TextStyle(font: font, fontSize: 9),
        ),
        pw.Text(
          '   g. Servizi igienico assistenziali',
          style: pw.TextStyle(font: font, fontSize: 9),
        ),
        pw.Text(
          '   h. Assistenza esterna',
          style: pw.TextStyle(font: font, fontSize: 9),
        ),
        pw.Text(
          '   i. Smart working',
          style: pw.TextStyle(font: font, fontSize: 9),
        ),
      ],
    );
  }

  pw.Widget _buildIndiceColonna2(pw.Font font) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          '3. Titolo III - Impianti, Macchine e Attrezzature',
          style: pw.TextStyle(font: font, fontSize: 9),
        ),
        pw.Text(
          '   a. Organizzazione del lavoro',
          style: pw.TextStyle(font: font, fontSize: 9),
        ),
        pw.Text(
          '   b. Macchine e attrezzature',
          style: pw.TextStyle(font: font, fontSize: 9),
        ),
        pw.Text(
          '   c. Apparecchi portatili',
          style: pw.TextStyle(font: font, fontSize: 9),
        ),
        pw.Text(
          '   d. Utensili manuali',
          style: pw.TextStyle(font: font, fontSize: 9),
        ),
        pw.Text(
          '   e. Mezzi di sollevamento materiali',
          style: pw.TextStyle(font: font, fontSize: 9),
        ),
        pw.Text(
          '   f. Carrelli elevatori',
          style: pw.TextStyle(font: font, fontSize: 9),
        ),
        pw.Text(
          '   g. Scaffalature metalliche',
          style: pw.TextStyle(font: font, fontSize: 9),
        ),
        pw.Text(
          '   h. Trabattelli',
          style: pw.TextStyle(font: font, fontSize: 9),
        ),
        pw.Text(
          '   i. Cancelli e serrande elettrici',
          style: pw.TextStyle(font: font, fontSize: 9),
        ),
        pw.Text(
          '   j. Mezzi di trasporto persone',
          style: pw.TextStyle(font: font, fontSize: 9),
        ),
        pw.Text(
          '   k. Impianti elettrici; scariche atmosferiche',
          style: pw.TextStyle(font: font, fontSize: 9),
        ),
        pw.Text(
          '   l. Impianti termici',
          style: pw.TextStyle(font: font, fontSize: 9),
        ),
        pw.Text(
          '   m. Ascensori, montacarichi, pedane',
          style: pw.TextStyle(font: font, fontSize: 9),
        ),
        pw.Text(
          '   n. Apparecchi in pressione',
          style: pw.TextStyle(font: font, fontSize: 9),
        ),
        pw.SizedBox(height: 10),
        pw.Text(
          '3.1 Uso dei Dispositivi di Protezione Individuale',
          style: pw.TextStyle(font: font, fontSize: 9),
        ),
        pw.SizedBox(height: 10),
        pw.Text(
          '4. Titolo IV - Cantieri temporanei e mobili',
          style: pw.TextStyle(font: font, fontSize: 9),
        ),
        pw.Text(
          '   a. Misure generali di salute e sicurezza',
          style: pw.TextStyle(font: font, fontSize: 9),
        ),
        pw.Text(
          '   b. Viabilità e recinzione',
          style: pw.TextStyle(font: font, fontSize: 9),
        ),
        pw.Text(
          '   c. Opere provvisionali',
          style: pw.TextStyle(font: font, fontSize: 9),
        ),
        pw.Text(
          '   d. Scavi e fondazioni',
          style: pw.TextStyle(font: font, fontSize: 9),
        ),
        pw.Text(
          '   e. Costruzioni edilizie',
          style: pw.TextStyle(font: font, fontSize: 9),
        ),
        pw.Text(
          '   f. Demolizioni',
          style: pw.TextStyle(font: font, fontSize: 9),
        ),
      ],
    );
  }

  pw.Widget _buildIndiceColonna3(pw.Font font) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          '5. Titolo V - Segnaletica di sicurezza',
          style: pw.TextStyle(font: font, fontSize: 9),
        ),
        pw.Text(
          '   a. Segnali di Sicurezza',
          style: pw.TextStyle(font: font, fontSize: 9),
        ),
        pw.Text(
          '   b. Segnali di emergenza',
          style: pw.TextStyle(font: font, fontSize: 9),
        ),
        pw.SizedBox(height: 10),
        pw.Text(
          '6. Titolo VI - Movimentazione manuale carichi',
          style: pw.TextStyle(font: font, fontSize: 9),
        ),
        pw.Text(
          '   a. Movimentazione manuale dei carichi',
          style: pw.TextStyle(font: font, fontSize: 9),
        ),
        pw.Text(
          '   b. Movimenti ripetitivi',
          style: pw.TextStyle(font: font, fontSize: 9),
        ),
        pw.Text(
          '   c. Rischi ergonomici',
          style: pw.TextStyle(font: font, fontSize: 9),
        ),
        pw.SizedBox(height: 10),
        pw.Text(
          '7. Titolo VII - Attrezzature con Videoterminali',
          style: pw.TextStyle(font: font, fontSize: 9),
        ),
        pw.SizedBox(height: 10),
        pw.Text(
          '8. Titolo VIII - Agenti fisici',
          style: pw.TextStyle(font: font, fontSize: 9),
        ),
        pw.Text('   a. Rumore', style: pw.TextStyle(font: font, fontSize: 9)),
        pw.Text(
          '   b. Vibrazioni meccaniche',
          style: pw.TextStyle(font: font, fontSize: 9),
        ),
        pw.Text(
          '   c. Campi elettromagnetici',
          style: pw.TextStyle(font: font, fontSize: 9),
        ),
        pw.Text(
          '   d. Radiazioni ottiche artificiali',
          style: pw.TextStyle(font: font, fontSize: 9),
        ),
        pw.Text(
          '   e. Radiazioni ionizzanti',
          style: pw.TextStyle(font: font, fontSize: 9),
        ),
        pw.SizedBox(height: 10),
        pw.Text(
          '9. Titolo IX - Sostanze pericolose',
          style: pw.TextStyle(font: font, fontSize: 9),
        ),
        pw.Text(
          '   a. Rischio chimico',
          style: pw.TextStyle(font: font, fontSize: 9),
        ),
        pw.Text(
          '   b. Rischi cancerogeni o mutageni',
          style: pw.TextStyle(font: font, fontSize: 9),
        ),
        pw.Text(
          '   c. Materiali con Amianto',
          style: pw.TextStyle(font: font, fontSize: 9),
        ),
        pw.SizedBox(height: 10),
        pw.Text(
          '10. Titolo X - Esposizione ad agenti Biologici',
          style: pw.TextStyle(font: font, fontSize: 9),
        ),
        pw.SizedBox(height: 10),
        pw.Text(
          '11. Titolo XI - Protezione da Atmosfere esplosive',
          style: pw.TextStyle(font: font, fontSize: 9),
        ),
      ],
    );
  }

  pw.Widget _buildHeader(
    Societa societa,
    UnitaLocale unitaLocale,
    Reparto reparto,
    pw.Font fontRegular,
    pw.Font fontBold,
  ) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Row(
        children: [
          pw.Text(
            'Società: ',
            style: pw.TextStyle(font: fontRegular, fontSize: 8),
          ),
          pw.Text(
            societa.nome,
            style: pw.TextStyle(font: fontBold, fontSize: 9),
          ),
          pw.SizedBox(width: 20),
          pw.Text(
            'Un. Produttiva: ',
            style: pw.TextStyle(font: fontRegular, fontSize: 8),
          ),
          pw.Text(
            unitaLocale.nome,
            style: pw.TextStyle(font: fontBold, fontSize: 9),
          ),
          pw.SizedBox(width: 20),
          pw.Text(
            'Reparto: ',
            style: pw.TextStyle(font: fontRegular, fontSize: 8),
          ),
          pw.Text(
            reparto.nome,
            style: pw.TextStyle(font: fontBold, fontSize: 9),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildFooter(
    pw.Context context,
    pw.MemoryImage? logo,
    String revisione,
    String dataValutazione,
    pw.Font font,
  ) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 10),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Row(
            children: [
              pw.Text(
                'Redatto a cura di: ',
                style: pw.TextStyle(font: font, fontSize: 10),
              ),
              if (logo != null) pw.Image(logo, height: 30),
            ],
          ),
          pw.Text(
            'Rev N. $revisione del: $dataValutazione - Pag. ${context.pageNumber} di ${context.pagesCount}',
            style: pw.TextStyle(font: font, fontSize: 10),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildProvvedimentiTable(
    List<Provvedimento> provvedimenti,
    pw.Font fontRegular,
    pw.Font fontBold,
    DateFormat dateFormat,
  ) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400),
      columnWidths: {
        0: const pw.FlexColumnWidth(1), // Rischio
        1: const pw.FlexColumnWidth(1), // Stima
        2: const pw.FlexColumnWidth(5), // Misure
        3: const pw.FlexColumnWidth(2), // Mansioni
        4: const pw.FlexColumnWidth(1), // Termine
      },
      children: [
        // Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            _buildTableCell('Rischio', fontBold, isHeader: true),
            _buildTableCell('Stima\n(PxD=R)', fontBold, isHeader: true),
            _buildTableCell(
              'Misure di prevenzione e protezione',
              fontBold,
              isHeader: true,
            ),
            _buildTableCell('Mansioni esposte', fontBold, isHeader: true),
            _buildTableCell('Termine\n(gg-mm-aa)', fontBold, isHeader: true),
          ],
        ),
        // Data rows
        ...provvedimenti.map(
          (p) => pw.TableRow(
            children: [
              _buildTableCell(p.rischio, fontRegular),
              _buildTableCell(
                '${p.stimaP} x ${p.stimaD} = ${p.stimaP * p.stimaD}',
                fontRegular,
                center: true,
              ),
              _buildTableCell(
                p.nome.replaceAll('\n', ' ').replaceAll('\r', ''),
                fontRegular,
              ),
              _buildTableCell(p.soggettiEsposti, fontRegular),
              _buildTableCell(
                p.dataScadenza != null
                    ? dateFormat.format(p.dataScadenza!)
                    : '',
                fontRegular,
              ),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _buildTableCell(
    String text,
    pw.Font font, {
    bool isHeader = false,
    bool center = false,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(4),
      alignment: center ? pw.Alignment.center : pw.Alignment.centerLeft,
      child: pw.Text(
        text,
        style: pw.TextStyle(font: font, fontSize: isHeader ? 10 : 9),
      ),
    );
  }
}
