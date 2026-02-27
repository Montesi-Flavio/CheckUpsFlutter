import 'package:postgres/postgres.dart';

void main() async {
  final pool = Pool.withEndpoints([
    Endpoint(
      host: 'localhost',
      database: 'checkups_db',
      username: 'postgres',
      password: 'postgres',
    ),
  ], settings: PoolSettings(maxConnectionCount: 1, sslMode: SslMode.disable));

  try {
    await pool.execute('''
      CREATE TABLE IF NOT EXISTS public.scadenze_interventi (
        id_scadenza INTEGER PRIMARY KEY,
        id_unita_locale INTEGER NOT NULL REFERENCES public.unita_locali(id_unita_locale) ON DELETE CASCADE,
        genere VARCHAR(255) NOT NULL,
        categoria VARCHAR(255) NOT NULL,
        type VARCHAR(255) NOT NULL,
        periodicita INTEGER NOT NULL DEFAULT 0,
        scadenza DATE,
        avviso_scadenza VARCHAR(255) NOT NULL,
        preavviso_assolto INTEGER NOT NULL DEFAULT 0,
        note TEXT
      );
    ''');
    print('Table created successfully');
  } catch (e) {
    print('Error: \$e');
  } finally {
    await pool.close();
  }
}
