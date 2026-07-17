import { NestMiddleware, Injectable } from '@nestjs/common';
import { Request, Response, NextFunction } from 'express';
import { v4 as uuidv4 } from 'uuid';

@Injectable()
export class CorrelationIdMiddleware implements NestMiddleware {
  use(req: Request, res: Response, next: NextFunction) {
    const correlationHeader = 'x-correlation-id';
    let correlationId = req.headers[correlationHeader] as string;

    if (!correlationId) {
      correlationId = uuidv4();
    }

    req.headers[correlationHeader] = correlationId;
    res.setHeader(correlationHeader, correlationId);
    (req as any).correlationId = correlationId;

    next();
  }
}
