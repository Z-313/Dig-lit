#!/bin/bash

# FRONTEND READINESS TEST
echo "🌐 FRONTEND CONNECTION TEST"
echo "=================================================="

# Start the backend
echo "🚀 Starting backend server..."
npm start &
BACKEND_PID=$!
sleep 3

# Create a simple frontend test HTML file
cat > frontend-test.html << 'HTML'
<!DOCTYPE html>
<html>
<head>
    <title>Dig-lit Frontend Test</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .container { max-width: 800px; margin: 0 auto; }
        .endpoint { background: #f5f5f5; padding: 15px; margin: 10px 0; border-radius: 5px; }
        .success { color: green; }
        .error { color: red; }
        button { padding: 10px 20px; margin: 5px; background: #007acc; color: white; border: none; border-radius: 4px; cursor: pointer; }
        pre { background: #f8f8f8; padding: 10px; border-radius: 4px; overflow-x: auto; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🌐 Dig-lit Frontend Connection Test</h1>
        <p>This tests if your frontend can connect to the backend API.</p>
        
        <div class="endpoint">
            <h3>1. Health Check</h3>
            <button onclick="testHealth()">Test /api/health</button>
            <div id="health-result"></div>
        </div>
        
        <div class="endpoint">
            <h3>2. Test API</h3>
            <button onclick="testApi()">Test /api/test</button>
            <div id="api-result"></div>
        </div>
        
        <div class="endpoint">
            <h3>3. Main Endpoint</h3>
            <button onclick="testMain()">Test /</button>
            <div id="main-result"></div>
        </div>
    </div>

    <script>
        const backendUrl = 'http://localhost:3000';
        
        async function testHealth() {
            try {
                const response = await fetch(`${backendUrl}/api/health`);
                const data = await response.json();
                document.getElementById('health-result').innerHTML = 
                    `<p class="success">✅ Success!</p><pre>${JSON.stringify(data, null, 2)}</pre>`;
            } catch (error) {
                document.getElementById('health-result').innerHTML = 
                    `<p class="error">❌ Error: ${error.message}</p>`;
            }
        }
        
        async function testApi() {
            try {
                const response = await fetch(`${backendUrl}/api/test`);
                const data = await response.json();
                document.getElementById('api-result').innerHTML = 
                    `<p class="success">✅ Success!</p><pre>${JSON.stringify(data, null, 2)}</pre>`;
            } catch (error) {
                document.getElementById('api-result').innerHTML = 
                    `<p class="error">❌ Error: ${error.message}</p>`;
            }
        }
        
        async function testMain() {
            try {
                const response = await fetch(backendUrl);
                const data = await response.json();
                document.getElementById('main-result').innerHTML = 
                    `<p class="success">✅ Success!</p><pre>${JSON.stringify(data, null, 2)}</pre>`;
            } catch (error) {
                document.getElementById('main-result').innerHTML = 
                    `<p class="error">❌ Error: ${error.message}</p>`;
            }
        }
    </script>
</body>
</html>
HTML

echo "✅ Created frontend test file: frontend-test.html"
echo ""
echo "🌐 OPEN THIS FILE IN YOUR BROWSER:"
echo "   file://$(pwd)/frontend-test.html"
echo ""
echo "📝 INSTRUCTIONS:"
echo "   1. Make sure backend is running: npm start"
echo "   2. Open frontend-test.html in a web browser"
echo "   3. Click the test buttons to verify frontend-backend connection"
echo ""
echo "🎯 BACKEND IS CURRENTLY RUNNING ON: http://localhost:3000"

# Keep the backend running for testing
echo ""
read -p "Press Enter to stop the backend server..."
kill $BACKEND_PID