import React from 'react';
import { useVoiceAssistant } from '@/hooks/useVoiceAssistant';

export const VoiceAssistantButton: React.FC = () => {
  const { isListening, toggleListening } = useVoiceAssistant();

  return (
    <button
      onClick={toggleListening}
      className="rounded-xl bg-indigo-600 px-4 py-2 text-white hover:bg-indigo-700 transition"
    >
      {isListening ? '🎙️ Listening...' : '🎤 Start Voice'}
    </button>
  );
};
