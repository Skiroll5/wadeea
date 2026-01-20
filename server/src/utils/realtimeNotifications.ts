import { getIO } from '../socket';

export type RealtimeNotificationLevel = 'info' | 'success' | 'warning' | 'error';
export type RealtimeNotificationAudience = 'all' | 'admins' | 'user';

export interface RealtimeNotificationPayload {
    level: RealtimeNotificationLevel;
    title: string;
    message: string;
    audience?: RealtimeNotificationAudience;
    targetUserId?: string;
    entityType?: string;
    entityId?: string;
    classId?: string;
}

export const emitAppNotification = (payload: RealtimeNotificationPayload) => {
    const io = getIO();
    io.emit('app_notification', payload);
};
