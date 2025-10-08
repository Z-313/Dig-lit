import React from 'react';
import { ParticleBackground } from '../components/ui/ParticleBackground';
import { QuantumButton } from '../components/ui/QuantumButton';

const Home: React.FC = () => {
  return (
    <div className="min-h-screen bg-gradient-to-br from-purple-900 via-blue-900 to-indigo-900">
      <ParticleBackground />

      <div className="relative z-10 flex flex-col items-center justify-center min-h-screen text-white">
        <div className="text-center">
          <h1 className="text-6xl font-bold mb-6 bg-clip-text text-transparent bg-gradient-to-r from-cyan-400 to-blue-500">
            Dig-lit AI
          </h1>
          <p className="text-xl mb-8 text-gray-300 max-w-2xl">
            Quantum-inspired AI platform for creative generation and business
            intelligence
          </p>

          <div className="flex gap-4 justify-center">
            <QuantumButton
              onClick={() => (window.location.href = '/dashboard')}
              variant="primary"
            >
              Launch Studio
            </QuantumButton>
            <QuantumButton
              onClick={() => (window.location.href = '/ai-chat')}
              variant="secondary"
            >
              Try AI Chat
            </QuantumButton>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Home;
