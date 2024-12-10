from gtts import gTTS
import os
import tempfile
import platform

def speak(text: str, lang: str='en'):
    """
    Converts text to speech and plays the audio using the system's default media player.
    
    Parameters:
    - text (str): The text to be converted to speech
    - lang (str, optional): The language code for text-to-speech conversion. Defaults to 'en' (English)
    """
    with tempfile.NamedTemporaryFile(delete=False, suffix=".mp3") as temp_file: 
        temp_path = temp_file.name
        tts = gTTS(text=text, lang=lang)
        tts.save(temp_path) 

    try: 
       if platform.system() == "Windows":
            os.system(f"start {temp_path}")
       elif platform.system() == "Darwin":  # macOS
            os.system(f"open {temp_path}")
       else:
            os.system(f"xdg-open {temp_path}")   
    finally: 
        pass
    
if __name__ == "__main__": 
    speak("Hello darkness my old friend")
    
    