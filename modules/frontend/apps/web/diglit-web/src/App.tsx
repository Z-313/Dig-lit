import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import Home from './pages/Home';
import Dashboard from './pages/Dashboard';
import { ChatInterface } from './components/ai/ChatInterface';

function App() {
  return (
    <Router>
      <Routes>
        <Route path="/" element={<Home />} />
        <Route path="/dashboard" element={<Dashboard />} />
        <Route
          path="/ai-chat"
          element={
            <div className="min-h-screen bg-gray-50 p-8">
              <div className="max-w-4xl mx-auto">
                <h1 className="text-3xl font-bold text-gray-900 mb-6">
                  AI Chat Interface
                </h1>
                <ChatInterface />
              </div>
            </div>
          }
        />
      </Routes>
    </Router>
  );
}

export default App;
