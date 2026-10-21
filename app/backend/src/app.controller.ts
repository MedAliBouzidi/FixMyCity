import { Controller, Get } from '@nestjs/common';
import * as os from 'os';
import { DbService } from './db.service.js';

@Controller()
export class AppController {
  constructor(private readonly db: DbService) {}

  // Liveness only: no DB call, so an RDS blip never marks the backend unhealthy in the ALB.
  @Get('health')
  health() {
    return { status: 'ok', uptimeSeconds: Math.round(process.uptime()) };
  }

  @Get('info')
  async info() {
    return {
      backend: {
        environment: process.env.APP_ENV,
        hostname: os.hostname(), // container id
        nodeVersion: process.version,
        uptimeSeconds: Math.round(process.uptime()),
        memoryMb: Math.round(process.memoryUsage().rss / 1024 / 1024),
        time: new Date().toISOString(),
      },
      database: await this.db.status(),
    };
  }
}
