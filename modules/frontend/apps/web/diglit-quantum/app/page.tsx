import React from 'react';
import { VoiceAssistantButton } from '@/components/voice/VoiceAssistantButton';

export default function Home() {
  return (
    <main className="min-h-screen bg-gradient-to-br from-slate-950 via-purple-950 to-slate-900">
      <div className="container mx-auto px-4 py-16">
        <section className="text-center space-y-8">
          <h1 className="text-6xl font-bold bg-clip-text text-transparent bg-gradient-to-r from-cyan-400 via-purple-400 to-pink-400">
            Dig|lit Quantum
          </h1>

          <p className="text-xl text-gray-300 max-w-2xl mx-auto">
            AI-powered quantum interface for next-generation digital experiences
          </p>

          <div className="flex gap-4 justify-center items-center">
            <VoiceAssistantButton />
          </div>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mt-16">
            <FeatureCard
              title="🧠 AI Engine"
              description="Multi-modal AI with voice, vision, and language understanding"
            />
            <FeatureCard
              title="👁️ Visual Engine"
              description="Quantum aesthetics with 3D rendering and holographic effects"
            />
            <FeatureCard
              title="📊 Analytics"
              description="Real-time intelligence and performance monitoring"
            />
          </div>
        </section>
      </div>
    </main>
  );
}

function FeatureCard({
  title,
  description,
}: {
  title: string;
  description: string;
}) {
  return (
    <div className="bg-slate-900/50 backdrop-blur-sm border border-purple-500/20 rounded-lg p-6 hover:border-purple-500/40 transition-colors">
      <h3 className="text-xl font-semibold mb-2 text-cyan-400">{title}</h3>
      <p className="text-gray-400">{description}</p>
    </div>
  );
}
