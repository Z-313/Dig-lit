import React from 'react';
import { useAI } from '../hooks/useAI';

const Dashboard: React.FC = () => {
  const { metrics, isLoading } = useAI();

  return (
    <div className="min-h-screen bg-gray-50 p-6">
      <div className="max-w-7xl mx-auto">
        <h1 className="text-3xl font-bold text-gray-900 mb-8">
          AI Studio Dashboard
        </h1>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
          <div className="bg-white rounded-lg shadow p-6">
            <h3 className="text-lg font-semibold text-gray-700">
              Models Loaded
            </h3>
            <p className="text-2xl font-bold text-blue-600">
              {metrics?.modelsLoaded || 0}
            </p>
          </div>

          <div className="bg-white rounded-lg shadow p-6">
            <h3 className="text-lg font-semibold text-gray-700">
              Inference Count
            </h3>
            <p className="text-2xl font-bold text-green-600">
              {metrics?.inferenceCount || 0}
            </p>
          </div>

          <div className="bg-white rounded-lg shadow p-6">
            <h3 className="text-lg font-semibold text-gray-700">
              Memory Usage
            </h3>
            <p className="text-2xl font-bold text-orange-600">
              {metrics?.memoryUsage || '0'}%
            </p>
          </div>

          <div className="bg-white rounded-lg shadow p-6">
            <h3 className="text-lg font-semibold text-gray-700">
              Quantum Score
            </h3>
            <p className="text-2xl font-bold text-purple-600">
              {metrics?.quantumScore || '0.0'}
            </p>
          </div>
        </div>

        <div className="bg-white rounded-lg shadow p-6">
          <h2 className="text-xl font-semibold mb-4">Quick Actions</h2>
          <div className="flex gap-4">
            <button
              onClick={() => (window.location.href = '/ai-chat')}
              className="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600"
            >
              AI Chat
            </button>
            <button className="px-4 py-2 bg-green-500 text-white rounded hover:bg-green-600">
              Visual Generator
            </button>
            <button className="px-4 py-2 bg-purple-500 text-white rounded hover:bg-purple-600">
              Analytics
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Dashboard;
