
import { PrismaClient } from '@prisma/client';
import { sendDataNotification } from '../services/notificationService';

const prisma = new PrismaClient();

// Notification Types mapped to preference fields
export type NotificationType =
    | 'noteAdded'
    | 'noteUpdated'
    | 'attendanceRecorded'
    | 'birthdayReminder'
    | 'inactiveStudent'
    | 'newUserRegistered';

export const notifyClassManagers = async (
    classId: string,
    type: NotificationType,
    title: string,
    body: string,
    data: Record<string, string> = {},
    excludeUserId?: string
) => {
    try {
        // Find all managers for this class
        const managers = await prisma.classManager.findMany({
            where: { classId },
            include: {
                user: {
                    include: { notificationPreference: true }
                }
            }
        });

        const tokens: string[] = [];

        for (const mgr of managers) {
            const user = mgr.user;
            if (user.id === excludeUserId) continue; // Don't notify sender
            if (!user.fcmToken) continue; // No token
            if (user.isDeleted || !user.isActive) continue;

            // Check preference
            // @ts-ignore
            const prefs = user.notificationPreference;
            if (prefs && !prefs[type]) continue; // User disabled this type

            tokens.push(user.fcmToken);
        }

        // Also notify admins who want this notification
        const admins = await prisma.user.findMany({
            where: { role: 'ADMIN', isActive: true, isDeleted: false },
            include: { notificationPreference: true }
        });

        for (const admin of admins) {
            if (admin.id === excludeUserId) continue;
            // distinct check handled by Set if needed, but for now simple check
            // Avoid duplicates if admin is also a manager (unlikely but possible)
            if (managers.some((m: any) => m.userId === admin.id)) continue;

            if (!admin.fcmToken) continue;
            // @ts-ignore
            const prefs = admin.notificationPreference;
            if (prefs && !prefs[type]) continue;

            tokens.push(admin.fcmToken);
        }

        if (tokens.length > 0) {
            await sendDataNotification(tokens, title, body, data);
        }

    } catch (error) {
        console.error('Error in notifyClassManagers:', error);
    }
};

export const notifyAdmins = async (
    type: NotificationType,
    title: string,
    body: string,
    data: Record<string, string> = {},
    excludeUserId?: string
) => {
    try {
        const admins = await prisma.user.findMany({
            where: { role: 'ADMIN', isActive: true, isDeleted: false },
            include: { notificationPreference: true }
        });

        const tokens: string[] = [];

        for (const admin of admins) {
            if (admin.id === excludeUserId) continue;
            if (!admin.fcmToken) continue;

            // @ts-ignore
            const prefs = admin.notificationPreference;
            if (prefs && !prefs[type]) continue;

            tokens.push(admin.fcmToken);
        }

        if (tokens.length > 0) {
            await sendDataNotification(tokens, title, body, data);
        }
    } catch (error) {
        console.error('Error in notifyAdmins:', error);
    }
};

export const notifyUser = async (
    userId: string,
    title: string,
    body: string,
    data: Record<string, string> = {}
) => {
    try {
        const user = await prisma.user.findUnique({
            where: { id: userId },
        });

        if (user && user.fcmToken && user.isActive && !user.isDeleted) {
            await sendDataNotification([user.fcmToken], title, body, data);
        }
    } catch (error) {
        console.error('Error in notifyUser:', error);
    }
};
