
import { Request, Response } from 'express';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();
const JWT_SECRET = process.env.JWT_SECRET || 'changeme';

export const register = async (req: Request, res: Response) => {
    try {
        const { email, password, name, role } = req.body;

        const existingUser = await prisma.user.findUnique({ where: { email } });
        if (existingUser) return res.status(400).json({ message: 'User already exists' });

        const hashedPassword = await bcrypt.hash(password, 10);
        const userRole = role === 'ADMIN' ? 'ADMIN' : 'SERVANT'; // Simple protection, maybe improve later

        // If it's the FIRST user, make them ADMIN automatically?
        const userCount = await prisma.user.count();
        const finalRole = userCount === 0 ? 'ADMIN' : userRole;
        const isActive = finalRole === 'ADMIN'; // First admin active by default

        const user = await prisma.user.create({
            data: {
                email,
                password: hashedPassword,
                name,
                role: finalRole,
                isActive: isActive,
            },
        });

        res.status(201).json({ message: 'User created', user: { id: user.id, email: user.email, role: user.role, isActive: user.isActive } });
    } catch (error) {
        res.status(500).json({ message: 'Server error', error });
    }
};

export const login = async (req: Request, res: Response) => {
    try {
        const { email, password } = req.body;
        const user = await prisma.user.findUnique({ where: { email } });

        if (!user) return res.status(400).json({ message: 'Invalid credentials' });
        if (user.isDeleted) return res.status(403).json({ message: 'Account deleted' });

        const isMatch = await bcrypt.compare(password, user.password);
        if (!isMatch) return res.status(400).json({ message: 'Invalid credentials' });

        if (!user.isActive) {
            return res.status(403).json({ message: 'Account pending approval', code: 'PENDING_APPROVAL' });
        }

        const token = jwt.sign({ userId: user.id, role: user.role }, JWT_SECRET, { expiresIn: '1h' });

        res.json({ token, user: { id: user.id, email: user.email, name: user.name, role: user.role } });
    } catch (error) {
        res.status(500).json({ message: 'Server error', error });
    }
};
