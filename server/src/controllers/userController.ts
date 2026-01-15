
import { Request, Response } from 'express';
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

export const activateUser = async (req: Request, res: Response) => {
    try {
        const { userId } = req.body;
        if (!userId) return res.status(400).json({ message: 'UserId required' });

        const user = await prisma.user.update({
            where: { id: userId },
            data: { isActive: true },
        });

        res.json({ message: 'User activated', user: { id: user.id, isActive: user.isActive } });
    } catch (error) {
        res.status(500).json({ message: 'Server error', error });
    }
};

export const listPendingUsers = async (req: Request, res: Response) => {
    try {
        const users = await prisma.user.findMany({
            where: { isActive: false, role: 'SERVANT', isDeleted: false },
            select: { id: true, name: true, email: true, createdAt: true },
        });
        res.json(users);
    } catch (error) {
        res.status(500).json({ message: 'Server error', error });
    }
};
