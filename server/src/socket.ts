import { Server } from 'socket.io';

let io: Server | null = null;

export const setIO = (socketIO: Server) => {
    io = socketIO;
};

export const getIO = (): Server => {
    if (!io) {
        console.warn('Socket.io requested but not initialized yet. This might be fine during startup.');
        // Return a dummy object or throw? Throwing is safer for logic relying on it.
        // But to avoid crashes in async jobs/hooks that might fire early:
        throw new Error('Socket.io not initialized');
    }
    return io;
};
