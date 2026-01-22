
import admin from 'firebase-admin';
import path from 'path';
import fs from 'fs';

let isInitialized = false;

export const initFirebase = async () => {
    try {
        if (isInitialized) return;

        // 1. Try environment variable for credential (JSON content or path)
        if (process.env.GOOGLE_APPLICATION_CREDENTIALS) {
            const envCred = process.env.GOOGLE_APPLICATION_CREDENTIALS;
            let credential;

            // Check if it's a file path
            if (fs.existsSync(envCred)) {
                 // It's a path
                 credential = admin.credential.cert(envCred);
            } else {
                 // Try parsing as JSON content
                 try {
                     const serviceAccount = JSON.parse(envCred);
                     credential = admin.credential.cert(serviceAccount);
                 } catch (e) {
                     // Not a valid JSON, and not a file.
                     console.warn('GOOGLE_APPLICATION_CREDENTIALS set but invalid path or JSON. Falling back to default.');
                 }
            }

            if (credential) {
                admin.initializeApp({ credential });
                isInitialized = true;
                console.log('Firebase Admin initialized via GOOGLE_APPLICATION_CREDENTIALS');
                return;
            }
        }

        // 2. Try default file path 'service-account.json' in server root
        // Assuming this file is compiled to dist, or we resolve relative to src
        const defaultPath = path.resolve(process.cwd(), 'service-account.json');
        if (fs.existsSync(defaultPath)) {
            admin.initializeApp({
                credential: admin.credential.cert(defaultPath)
            });
            isInitialized = true;
            console.log('Firebase Admin initialized via default service-account.json');
            return;
        }

        console.warn('Firebase Service Account not found. Push notifications will NOT be sent.');

    } catch (error) {
        console.error('Failed to initialize Firebase Admin:', error);
    }
};

export const sendDataNotification = async (tokens: string[], title: string, body: string, data?: Record<string, string>) => {
    if (!isInitialized) {
        // console.debug('Firebase not initialized, skipping notification.');
        return;
    }
    if (tokens.length === 0) return;

    try {
        const message: admin.messaging.MulticastMessage = {
            tokens,
            notification: {
                title,
                body,
            },
            data,
            android: {
                priority: 'high',
                notification: {
                    sound: 'default',
                    channelId: 'default_channel',
                },
            },
            apns: {
                payload: {
                    aps: {
                        sound: 'default',
                        contentAvailable: true,
                    },
                },
            },
        };

        const response = await admin.messaging().sendEachForMulticast(message);
        console.log(`Sent notification: ${response.successCount} successful, ${response.failureCount} failed`);

        if (response.failureCount > 0) {
            const failedTokens: string[] = [];
            response.responses.forEach((resp, idx) => {
                if (!resp.success) {
                    failedTokens.push(tokens[idx]);
                    // Potentially remove invalid tokens from DB here
                }
            });
            console.warn('Failed tokens:', failedTokens);
        }
    } catch (error) {
        console.error('Error sending notification:', error);
    }
};
