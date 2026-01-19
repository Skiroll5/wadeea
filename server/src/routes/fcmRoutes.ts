
import { Router } from 'express';
import { PrismaClient } from '@prisma/client';
import { AuthRequest } from '../middleware/authMiddleware';

const router = Router();
const prisma = new PrismaClient();

// Register or update FCM token
router.post('/register', async (req: AuthRequest, res) => {
    try {
        // @ts-ignore
        const userId = req.user?.userId;
        const { token } = req.body;

        if (!userId || !token) {
            return res.status(400).json({ message: 'User ID and Token required' });
        }

        await prisma.user.update({
            where: { id: userId },
            data: { fcmToken: token },
        });

        res.json({ success: true, message: 'Token registered' });
    } catch (error) {
        console.error('FCM register error:', error);
        res.status(500).json({ message: 'Server error' });
    }
});

export default router;
