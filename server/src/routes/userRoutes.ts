
import express from 'express';
import {
    activateUser,
    abortActivation,
    listPendingUsers,
    listAbortedUsers,
    listAllUsers,
    enableUser,
    disableUser,
    deleteUser,
    updateProfile,

    saveStudentPreference,
    getStudentPreference,
    getNotificationPreferences,
    updateNotificationPreferences
} from '../controllers/userController';
import { authenticateToken, requireAdmin } from '../middleware/authMiddleware';

const router = express.Router();

// Public/Self routes (Authenticated)
router.put('/me', authenticateToken, updateProfile);
router.put('/me/students/:studentId/preference', authenticateToken, saveStudentPreference);
router.get('/me/students/:studentId/preference', authenticateToken, getStudentPreference);
router.get('/me/notifications/preferences', authenticateToken, getNotificationPreferences);
router.put('/me/notifications/preferences', authenticateToken, updateNotificationPreferences);

// Admin only routes
router.use(authenticateToken, requireAdmin);

router.get('/', listAllUsers);
router.get('/pending', listPendingUsers);
router.get('/aborted', listAbortedUsers);
router.post('/activate', activateUser);
router.post('/:id/enable', enableUser);
router.post('/:id/disable', disableUser);
router.post('/:id/abort-activation', abortActivation);
router.delete('/:id', deleteUser);

export default router;
