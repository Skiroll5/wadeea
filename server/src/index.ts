import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import authRoutes from './routes/authRoutes';
import userRoutes from './routes/userRoutes';
import syncRoutes from './routes/syncRoutes';

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(helmet());
app.use(express.json());

app.use('/auth', authRoutes);
app.use('/users', userRoutes);
app.use('/sync', syncRoutes);

app.get('/', (req, res) => {
    res.send('St. Refqa Efteqad API is running');
});

app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});
