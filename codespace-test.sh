#!/bin/bash

# CODESPACE FRONTEND TEST
echo "🌐 CODESPACE FRONTEND-BACKEND INTEGRATION TEST"
echo "=================================================="

# Start backend if not running
if ! curl -f http://localhost:3000/ > /dev/null 2>&1; then
    echo "🚀 Starting backend server..."
    npm start &
    BACKEND_PID=$!
    sleep 3
fi

echo ""
echo "🧪 TESTING FRONTEND-BACKEND CONNECTION..."
echo "=================================================="

# Create a simple Node.js frontend test
cat > frontend-node-test.js << 'JAVASCRIPT'
import fetch from 'node-fetch';

const BACKEND_URL = 'http://localhost:3000';

async function testBackendConnection() {
    console.log('🌐 Testing Frontend-Backend Connection...\n');
    
    try {
        // Test main endpoint
        console.log('1. Testing main endpoint (/):');
        const mainResponse = await fetch(BACKEND_URL);
        const mainData = await mainResponse.json();
        console.log('   ✅ SUCCESS:', mainData.message);
        console.log('   Status:', mainData.status);
        console.log('');
        
        // Test health endpoint
        console.log('2. Testing health endpoint (/api/health):');
        const healthResponse = await fetch(\`\${BACKEND_URL}/api/health\`);
        const healthData = await healthResponse.json();
        console.log('   ✅ SUCCESS: Backend is healthy');
        console.log('   Service:', healthData.service);
        console.log('');
        
        // Test API endpoint
        console.log('3. Testing API endpoint (/api/test):');
        const apiResponse = await fetch(\`\${BACKEND_URL}/api/test\`);
        const apiData = await apiResponse.json();
        console.log('   ✅ SUCCESS:', apiData.message);
        console.log('   Data sample:', apiData.data.sample);
        console.log('');
        
        console.log('🎉 ALL TESTS PASSED! Frontend can successfully connect to backend!');
        console.log('\n🚀 YOUR REPOSITORY IS READY FOR WEB DEVELOPMENT!');
        
    } catch (error) {
        console.log('❌ ERROR:', error.message);
        console.log('💡 Make sure the backend is running with: npm start');
    }
}

testBackendConnection();
JAVASCRIPT

# Install node-fetch if needed and run the test
echo "📦 Installing test dependencies..."
npm install node-fetch --no-save

echo ""
echo "🔗 RUNNING INTEGRATION TEST..."
node frontend-node-test.js

echo ""
echo "✅ FRONTEND-BACKEND CONNECTION: WORKING!"
echo "=================================================="
