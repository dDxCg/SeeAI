from azure.cognitiveservices.vision.computervision import ComputerVisionClient
from msrest.authentication import CognitiveServicesCredentials
import os
import sys
import time


endpoint = "https://seeai.cognitiveservices.azure.com/"
key = os.getenv("AZURE_COMPUTER_VISION_KEY")

if not key: 
    print("Error: API key not provided. Please set the environment variable 'AZURE_COMPUTER_VISION_KEY'.")
    sys.exit(1) 

client = ComputerVisionClient(endpoint, CognitiveServicesCredentials(key))

def generate_image_description(image_path: str) -> str:
    """
    Generate a description (caption) for an image file using the Azure Computer Vision service.

    This function sends the image to the Azure Computer Vision API to analyze its content
    and returns a textual description (caption) of the image.

    Parameters:
    - image_path (str): The path to the image file that needs to be analyzed.

    Returns:
    - str: A description (caption) of the image. If no caption is generated, a default message is returned.
    """
    
    try:
        with open(image_path, "rb") as image:
            analysis = client.analyze_image_in_stream(image, ["Description"])

        caption = analysis.description.captions[0].text if analysis.description.captions else "No description available."
        return caption

    except Exception as e:
        print(f"An error occurred: {e}")
        return "An error occurred while generating the image description."

def extract_text_from_image(image_path: str) -> str:
    """
    Extracts text from an image using the Azure Computer Vision OCR API.

    Parameters:
    - image_path (str): The path to the image file that needs to be analyzed.

    Returns:
    - str: The text extracted from the image. Returns an empty string if no text is found.
    """
    try:
        with open(image_path, "rb") as image_stream:
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

        return extracted_text

    except Exception as e:
        print(f"An error occurred: {e}")
        return "An error occurred while extracting text from the image."


if __name__ == "__main__":
    # print(generate_image_description(image_path="test_image.jpeg"))
    # print(extract_text_from_image(image_path="test_text_image.jpg"))
    pass