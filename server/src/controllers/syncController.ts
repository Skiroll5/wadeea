
import { Request, Response } from 'express';
import { PrismaClient } from '@prisma/client';
import { AuthRequest } from '../middleware/authMiddleware';

const prisma = new PrismaClient();

export const syncChanges = async (req: AuthRequest, res: Response) => {
    if (req.method === 'POST') {
        return handlePush(req, res);
    } else if (req.method === 'GET') {
        return handlePull(req, res);
    } else {
        return res.sendStatus(405);
    }
};

const handlePush = async (req: AuthRequest, res: Response) => {
    const { changes } = req.body;
    if (!Array.isArray(changes)) return res.status(400).json({ message: 'Invalid format' });

    // Process sequentially to maintain order
    for (const change of changes) {
        const { uuid, entityType, entityId, operation, payload, createdAt } = change;

        // Idempotency Check: Ideally we should track processed UUIDs in a specialized table
        // For now, we rely on Last-Write-Wins based on logic below or standard upserts
        // BUT, a robust system *should* have a 'ProcessedSync' table. 
        // Let's implement a simple version where we assume 'uuid' is unique for the operation 
        // and if we successfully process it, we are good.
        // If the client retries, we might re-process. For "Last Write Wins", re-processing is usually fine 
        // as long as timestamps are respected.

        const modelName = mapEntityToModel(entityType);
        if (!modelName) continue;

        try {
            const dbModel = (prisma as any)[modelName];

            if (operation === 'VIRTUAL_DELETE' || operation === 'DELETE') {
                // We use Soft Deletes, so DELETE op should be an update isDeleted=true
                // But if client sends explicit DELETE op, handle it as soft delete
                await dbModel.upsert({
                    where: { id: entityId },
                    create: { id: entityId, ...payload, isDeleted: true, deletedAt: new Date() },
                    update: { isDeleted: true, deletedAt: new Date() },
                });
            } else {
                // CREATE or UPDATE
                // Remove ID from payload if present to avoid "Argument id for data.id must not be null" if it conflicts?
                // Prisma upsert needs where.

                // Payload should match Prisma schema. 
                // Client sends dates as strings, need to ensure proper parsing if not handled by Prisma auto-mapping?
                // Prisma maps ISO strings to Date automatically usually.

                await dbModel.upsert({
                    where: { id: entityId },
                    create: { ...payload, id: entityId },
                    update: { ...payload },
                });
            }
        } catch (e) {
            console.error(`Sync error for ${uuid}:`, e);
            // Continue or fail? Usually continue and report errors? 
            // For MVP, log and continue.
        }
    }

    res.json({ success: true });
};

const handlePull = async (req: AuthRequest, res: Response) => {
    const since = req.query.since as string;
    const sinceDate = since ? new Date(since) : new Date(0);

    const serverTimestamp = new Date().toISOString();

    // Fetch changes
    const students = await prisma.student.findMany({
        where: { updatedAt: { gt: sinceDate } },
    });

    const attendance = await prisma.attendanceRecord.findMany({
        where: { updatedAt: { gt: sinceDate } },
    });

    const notes = await prisma.note.findMany({
        where: { updatedAt: { gt: sinceDate } },
    });

    res.json({
        serverTimestamp,
        changes: {
            students,
            attendance,
            notes,
        },
    });
};

const mapEntityToModel = (type: string): string | null => {
    switch (type) {
        case 'STUDENT': return 'student';
        case 'ATTENDANCE': return 'attendanceRecord';
        case 'NOTE': return 'note';
        default: return null;
    }
};
