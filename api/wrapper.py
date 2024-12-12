from fastapi import FastAPI, File, UploadFile, HTTPException
import os
from azure.cognitiveservices.vision.computervision import ComputerVisionClient
from msrest.authentication import CognitiveServicesCredentials
import time

app = FastAPI()

endpoint = "https://seeai.cognitiveservices.azure.com/"
key = os.getenv("AZURE_COMPUTER_VISION_KEY")

if not key:
    raise RuntimeError("API key not provided. Please set the environment variable 'AZURE_COMPUTER_VISION_KEY'.")

client = ComputerVisionClient(endpoint, CognitiveServicesCredentials(key))


@app.post("/caption")
async def generate_caption(file: UploadFile = File(...)):
    """
    Endpoint to generate a description (caption) for an uploaded image.

    Parameters:
    - file: The uploaded image file (binary).

    Returns:
    - A JSON response with the image description.
    """
    try:
        with open(file.filename, "wb") as buffer:
            buffer.write(await file.read())

        with open(file.filename, "rb") as image:
            analysis = client.analyze_image_in_stream(image, ["Description"])

        caption = analysis.description.captions[0].text if analysis.description.captions else "No description available."
        return {"description": caption}

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"An error occurred: {e}")

    finally:
        if os.path.exists(file.filename):
            os.remove(file.filename)
            
            
@app.post("/text")
async def retrieve_text(file: UploadFile = File(...)):
    """
    Endpoint to extract text from an uploaded image.

    Parameters:
    - file: The uploaded image file (binary).

    Returns:
    - A JSON response with the extracted text.
    """
    try:
        with open(file.filename, "wb") as buffer:
            buffer.write(await file.read())

        with open(file.filename, "rb") as image_stream:
            result = client.read_in_stream(image_stream, raw=True)
            operation_location = result.headers["Operation-Location"]

            while True:
                read_result = client.get_read_result(operation_location.split('/')[-1])
                if read_result.status not in ['notStarted', 'running']:
                    break
                time.sleep(1)

        extracted_text = ""
        if read_result.status == 'succeeded':
            for text_result in read_result.analyze_result.read_results:
                for line in text_result.lines:
                    extracted_text += line.text + "\n"

        return {"text": extracted_text.strip()}

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"An error occurred: {e}")

    finally:
        if os.path.exists(file.filename):
            os.remove(file.filename)

@app.get("/health")
def check_health():
    return {"status":"ok"}