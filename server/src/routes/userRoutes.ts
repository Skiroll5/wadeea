
import express from 'express';
import { activateUser, listPendingUsers, updateProfile, saveStudentPreference, getStudentPreference } from '../controllers/userController';
import { authenticateToken, requireAdmin } from '../middleware/authMiddleware';

const router = express.Router();

// Public/Self routes (Authenticated)
router.put('/me', authenticateToken, updateProfile);
router.put('/me/students/:studentId/preference', authenticateToken, saveStudentPreference);
router.get('/me/students/:studentId/preference', authenticateToken, getStudentPreference);

// Admin only routes
router.use(authenticateToken, requireAdmin);

router.post('/activate', activateUser);
router.get('/pending', listPendingUsers);

export default router;
