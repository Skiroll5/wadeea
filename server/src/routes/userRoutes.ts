
import express from 'express';
import { activateUser, listPendingUsers } from '../controllers/userController';
import { authenticateToken, requireAdmin } from '../middleware/authMiddleware';

const router = express.Router();

// All routes here require ADMIN role
router.use(authenticateToken, requireAdmin);

router.post('/activate', activateUser);
router.get('/pending', listPendingUsers);

export default router;
