import { useState } from 'react';

export const useVoiceAssistant = () => {
  const [isListening, setListening] = useState(false);

  const toggleListening = () => setListening(!isListening);

  return { isListening, toggleListening };
};
