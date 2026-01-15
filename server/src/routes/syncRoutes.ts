
import express from 'express';
import { syncChanges } from '../controllers/syncController';
import { authenticateToken } from '../middleware/authMiddleware';

const router = express.Router();

router.use(authenticateToken);
router.all('/', syncChanges); // Handle both GET and POST on /sync

export default router;
