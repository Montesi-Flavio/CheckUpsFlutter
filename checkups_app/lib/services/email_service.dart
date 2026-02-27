import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import '../repositories/database_repository.dart';

class EmailService {
  final String username;
  late final String password; // Inserisci qui l'app password
  late final SmtpServer smtpServer;

  // Usa l'email da cui vuoi far partire le mail (Es. mario.rossi@gmail.com)
  // Per Gmail dovrai generare una password per le app: https://myaccount.google.com/apppasswords
  EmailService({required this.username, required String initialPassword}) {
    password = initialPassword;
    smtpServer = gmail(username, password);
  }

  Future<void> sendEmail({
    required String to,
    required String subject,
    required String text,
    String? html,
  }) async {
    final message = Message()
      ..from = Address(username, 'CheckUps System')
      ..recipients.add(to)
      ..subject = subject
      ..text = text
      ..html = html;

    try {
      await send(message, smtpServer);
      print('Email sent successfully to \$to');
    } on MailerException catch (e) {
      print('Message not sent to \$to. \\n\${e.toString()}');
      for (var p in e.problems) {
        print('Problem: \${p.code}: \${p.msg}');
      }
    }
  }

  Future<int> checkAndSendDeadlines(DatabaseRepository repo) async {
    int sentCount = 0;
    try {
      // 1. Get scadenze in scadenza (es. entro 30 giorni) e non risolte
      final result = await repo.getScadenzeForAutomatedEmail();

      for (var row in result) {
        final email = row['email'];
        final scadenza = row['scadenza'];
        final idScadenza = row['id_scadenza'];

        if (email != null && email.toString().isNotEmpty) {
          final scadenzaStr = scadenza.toString().split(' ')[0];
          await sendEmail(
            to: email.toString(),
            subject: 'Avviso Scadenza Intervento CheckUps',
            text: '''Buongiorno,

Le ricordiamo che vi è un intervento in scadenza il \$scadenzaStr:

Genere: \${row['genere']}
Categoria: \${row['categoria']}

Cordiali Saluti,
CheckUps System''',
          );

          // Aggiorna come inviato
          await repo.updateCampoInt(
            'scadenze_interventi',
            'id_scadenza',
            int.parse(idScadenza.toString()),
            'preavviso_assolto',
            1,
          );
          sentCount++;
        }
      }
    } catch (e) {
      print('Error during automated deadline check: \$e');
    }
    return sentCount;
  }
}
