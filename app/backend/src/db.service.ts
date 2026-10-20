import { Injectable, OnModuleDestroy } from '@nestjs/common';
import { createPool, Pool } from 'mysql2/promise';

@Injectable()
export class DbService implements OnModuleDestroy {
  private pool: Pool = createPool({
    host: process.env.DB_HOST,
    port: Number(process.env.DB_PORT ?? 3306),
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    connectionLimit: 5,
    connectTimeout: 5000,
    // For real use, load the RDS CA bundle instead of disabling verification.
    ssl: process.env.DB_SSL === 'true' ? { rejectUnauthorized: false } : undefined,
  });

  async status() {
    const start = Date.now();
    try {
      const [rows] = await this.pool.query('SELECT VERSION() AS version, DATABASE() AS db');
      const r = (rows as any[])[0];
      return {
        status: 'up',
        engine: 'MySQL',
        version: r.version,
        database: r.db,
        host: process.env.DB_HOST,
        latencyMs: Date.now() - start,
      };
    } catch (e: any) {
      return { status: 'down', host: process.env.DB_HOST, error: e.code ?? e.message };
    }
  }

  async onModuleDestroy() {
    await this.pool.end();
  }
}
