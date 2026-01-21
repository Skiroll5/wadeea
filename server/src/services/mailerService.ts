
/**
 * Mock Mailer Service
 * In a real application, you would use a library like nodemailer or an API like SendGrid.
 * For now, this service logs tokens and messages to the console.
 */

export const sendConfirmationEmail = async (email: string, token: string) => {
    console.log('\n--- EMAIL CONFIRMATION ---');
    console.log(`To: ${email}`);
    console.log(`Token: ${token}`);
    console.log(`Link: http://localhost:3000/api/auth/confirm-email?token=${token}`);
    console.log('--------------------------\n');
};

export const sendPasswordResetEmail = async (email: string, token: string) => {
    console.log('\n--- PASSWORD RESET (EMAIL) ---');
    console.log(`To: ${email}`);
    console.log(`Token: ${token}`);
    console.log(`Link: http://localhost:3000/api/auth/reset-password?token=${token}`);
    console.log('------------------------------\n');
};

export const sendPasswordResetSms = async (phone: string, token: string) => {
    console.log('\n--- PASSWORD RESET (SMS) ---');
    console.log(`To: ${phone}`);
    console.log(`Token/OTP: ${token}`);
    console.log('----------------------------\n');
};
