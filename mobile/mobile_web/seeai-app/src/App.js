import React, { useState, useRef, useEffect } from 'react';
import Webcam from 'react-webcam';
import { Camera, RefreshCw } from 'lucide-react';
import axios from 'axios';

const AccessibilityCameraApp = () => {
  const webcamRef = useRef(null);
  const [capturedImage, setCapturedImage] = useState(null);
  const [imageDescription, setImageDescription] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [cameraFacingMode, setCameraFacingMode] = useState('environment');
  const [error, setError] = useState(null);
  const [isListening, setIsListening] = useState(false);
  const instructionAudio = new Audio(process.env.PUBLIC_URL + '/sounds/instruction.mp3');
  const captureSound = new Audio(process.env.PUBLIC_URL + '/sounds/camera_shutter.mp3');
  const errorSound = new Audio(process.env.PUBLIC_URL + '/sounds/error.mp3');
  const successSound = new Audio(process.env.PUBLIC_URL + '/sounds/success.mp3');
  const [mode, setMode] = useState('caption');
  
  
  useEffect(() => {
    instructionAudio.load();
    const playInitialInstruction = async () => {
      try {
        await instructionAudio.play();
      } catch (error) {
        console.log('Waiting for user interaction before playing audio');
      }
    };
  
    playInitialInstruction();
    captureSound.load();
    errorSound.load();
    successSound.load();
  }, []);

  const speakDescription = (text) => {
    if ('speechSynthesis' in window) {
      window.speechSynthesis.cancel();
      const utterance = new SpeechSynthesisUtterance(text);
      utterance.lang = 'en-US';
      utterance.rate = 0.8;
      window.speechSynthesis.speak(utterance);
      console.log(text)
    }
  };
  
  const startVoiceCommand = () => {
    const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition;
    const recognition = new SpeechRecognition();

    recognition.continuous = true;
    recognition.interimResults = true;
    recognition.lang = 'en-US';
    
    let isSwitching = false;

    recognition.onstart = () => {
      setIsListening(true);
    };

    recognition.onresult = async (event) => {
      const transcript = Array.from(event.results)
        .map(result => result[0])
        .map(result => result.transcript)
        .join('');
      

      if (transcript.toLowerCase().includes('taking photo')) {
        captureAndAnalyzeImage();
      }
    
      if (transcript.toLowerCase().includes('caption') && !isSwitching) {
        isSwitching = true;
        setMode('caption');
        speakDescription('Switched to image caption mode');
        recognition.abort();
        setTimeout(() => {
          isSwitching = false;
        }, 20000);
      }
      
      if (transcript.toLowerCase().includes('text') && !isSwitching) {
        recognition.abort();
        isSwitching = true;
        setMode('text');
        speakDescription('Switched to text reading mode');
        setTimeout(() => {
          isSwitching = false;
        }, 20000);
      }

    };



    recognition.onerror = (event) => {
      console.error('Speech recognition error:', event.error);
    };

    recognition.onend = () => {
      recognition.start();
    };

    recognition.start();
  };
  
  // start using voice command
  
  useEffect(() => {
    startVoiceCommand();
    return () => {
      setIsListening(false);
    };
  }, []);

  const captureAndAnalyzeImage = async () => {
    captureSound.play();
    const key = process.env.REACT_APP_AZURE_COMPUTER_VISION_KEY;
    const endpoint = mode === 'caption' 
    ? "https://seeai.cognitiveservices.azure.com/computervision/imageanalysis:analyze?api-version=2024-02-01&features=caption"
    : "https://seeai.cognitiveservices.azure.com/computervision/imageanalysis:analyze?api-version=2024-02-01&features=read";
    try {
      const imageSrc = webcamRef.current.getScreenshot();
      setCapturedImage(imageSrc);
      setIsLoading(true);
      setError(null);
  
      const response = await fetch(imageSrc);
      const blob = await response.blob();
      const arrayBuffer = await blob.arrayBuffer();      
  
      const apiResponse = await axios.post(endpoint, arrayBuffer, {
        headers: {
          'Content-Type': 'application/octet-stream',
          'Ocp-Apim-Subscription-Key': key,
        }
      });
  
      if (mode === 'caption') {
        const captionText = apiResponse.data.captionResult?.text || 'Unable to analyze image';
        setImageDescription(captionText);
        speakDescription(captionText);
      } else {
        const blocks = apiResponse.data.readResult?.blocks || [];
        const extractedText = blocks
          .flatMap(block => block.lines)
          .map(line => line.text)
          .join(' ');
        
        setImageDescription(extractedText);
        speakDescription(extractedText);
      }
      
      setTimeout(() => {
        setCapturedImage(null);
        setImageDescription('');
      }, 2000); 
  
    } catch (err) {
      console.error('Image analysis error:', err);
      setError('Unable to analyze image. Please try again.');
      setImageDescription('');
    } finally {
      setIsLoading(false);
    }
  };
  

  const toggleCameraMode = () => {
    setCameraFacingMode(prevMode => 
      prevMode === 'environment' ? 'user' : 'environment'
    );
  };

  const resetCapture = () => {
    setCapturedImage(null);
    setImageDescription('');
  };

  const handleDoubleTap = (event) => {
    if (capturedImage) {
      resetCapture();
      speakDescription('Returned to camera mode');
    }
  };
    
  // useEffect(() => {
  //   const handleFirstTouch = () => {
  //     instructionAudio.play();
  //     // Remove the listener after first touch
  //     document.removeEventListener('touchstart', handleFirstTouch);
  //   };

  //   document.addEventListener('touchstart', handleFirstTouch);

  //   // Cleanup
  //   return () => {
  //     document.removeEventListener('touchstart', handleFirstTouch);
  //   };
  // }, []);

  return (
    <div className="flex flex-col h-screen">
      <div className="h-[50vh] relative">
        {capturedImage ? (
          <div 
          onClick={handleDoubleTap}
          className="w-full h-full"
        >
          <img
            src={capturedImage}
            alt="Captured"
            className="w-full h-full object-cover"
          />
          <div className="sr-only">
            Double tap anywhere to take new photo
          </div>
        </div>
        ) : (
          <Webcam
            audio={false}
            ref={webcamRef}
            screenshotFormat="image/jpeg"
            videoConstraints={{
              width: 1280,
              height: 720,
              facingMode: cameraFacingMode
            }}
            className="w-full h-full object-cover"
          />
        )}
      </div>
  
      <div className="h-[50vh] bg-blue-500">
        <button
          onClick={captureAndAnalyzeImage}
          className="w-full h-full flex flex-col justify-center items-center text-white"
          aria-label="Capture image"
        >
          <Camera size={48} />
          <span className="block mt-2 text-lg"></span>
        </button>
      </div>
    </div>
  )
  
  
};

export default AccessibilityCameraApp;