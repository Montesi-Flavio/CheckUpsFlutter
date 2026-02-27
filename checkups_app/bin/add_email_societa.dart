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
    await pool.execute(
      'ALTER TABLE public.societa ADD COLUMN IF NOT EXISTS email VARCHAR(255)',
    );
    print('Column email added successfully to societa table');
  } catch (e) {
    print('Error: \$e');
  } finally {
    await pool.close();
  }
}
