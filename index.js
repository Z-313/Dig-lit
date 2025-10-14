const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;

// Basic middleware
app.use(express.json());
app.use(express.static('public'));

// Health check endpoint
app.get('/', (req, res) => {
    res.json({
        message: '🚀 Dig-lit Quantum AI Platform is running!',
        status: 'OK',
        timestamp: new Date().toISOString(),
        version: '1.0.0-alpha.1'
    });
});

// API health check
app.get('/api/health', (req, res) => {
    res.json({ status: 'healthy', service: 'quantum-ai-platform' });
});

// Start server
app.listen(PORT, () => {
    console.log(`🌌 Quantum AI Platform running on http://localhost:${PORT}`);
    console.log(`📊 Health check: http://localhost:${PORT}/api/health`);
});

module.exports = app;
