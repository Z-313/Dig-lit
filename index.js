import express from 'express';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const app = express();
const PORT = process.env.PORT || 3000;

// Basic middleware
app.use(express.json());
app.use(express.static(join(__dirname, 'public')));

// Health check endpoint
app.get('/', (req, res) => {
    res.json({
        message: '🚀 Dig-lit Quantum AI Platform is running!',
        status: 'OK', 
        timestamp: new Date().toISOString(),
        version: '1.0.0-alpha.1',
        module: 'ES Modules'
    });
});

// API health check
app.get('/api/health', (req, res) => {
    res.json({ 
        status: 'healthy', 
        service: 'quantum-ai-platform',
        timestamp: new Date().toISOString()
    });
});

// Test endpoint
app.get('/api/test', (req, res) => {
    res.json({ 
        success: true,
        message: 'API is working correctly',
        data: { sample: 'This is test data from your backend' }
    });
});

// Start server
app.listen(PORT, () => {
    console.log('==================================================');
    console.log('🌌 QUANTUM AI PLATFORM - SERVER STARTED');
    console.log('==================================================');
    console.log(`📍 Local: http://localhost:${PORT}`);
    console.log(`📊 Health: http://localhost:${PORT}/api/health`);
    console.log(`🧪 Test API: http://localhost:${PORT}/api/test`);
    console.log('==================================================');
});

export default app;
