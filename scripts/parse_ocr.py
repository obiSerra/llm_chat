# /// script
# dependencies = [
# 'requests',
# 'ollama',
# 'Pillow',
# ]
# ///

import sys
from pathlib import Path
import requests
from ollama import Client
import json
from PIL import Image
import io

import argparse

# sys.path.insert(0, str(Path(__file__).parent))

# from list_models import print_model_list


def parse_arguments():
    parser = argparse.ArgumentParser(description="OCR Parsing Script")
    parser.add_argument(
        "--image-path",
        type=str,
        required=True,
        help="Path to the image file to be processed for OCR.",
    )

    return parser.parse_args()



# from ollama import Client
base_url = "http://localhost:11434"

if __name__ == "__main__":
    # print_model_list()

    args = parse_arguments()

    model_name = "deepseek-ocr:3b"
    
    print(f"[+] Using model: {model_name}")
    # Load the image and convert to grayscale
    image_path = args.image_path
    print(f"[+] Loading image from: {image_path}")
    image = Image.open(image_path)
    print(f"[+] Converting image to grayscale")
    grayscale_image = image.convert("L")
    # Save grayscale image to bytes
    img_byte_arr = io.BytesIO()
    grayscale_image.save(img_byte_arr, format='PNG')
    img_byte_arr.seek(0)
    
    client = Client(host=base_url, timeout=60)
    print(f"[+] Sending image to model for OCR parsing...")
    response = client.chat(
        model=model_name,
        messages=[
            {
                "role": "user",
                "content": "Parse the text in this image",
                "images": [img_byte_arr.getvalue()]
            },
        ],
    )

    if response.done and response.done_reason == "stop":
        print(f"[+] OCR Result:")

        total_duration = response.total_duration  / 1_000_000_000
        load_duration = response.load_duration  / 1_000_000_000
        prompt_eval_duration = response.prompt_eval_duration  / 1_000_000_000
        eval_duration = response.eval_duration  / 1_000_000_000

        print(f"    Total Duration: {total_duration} seconds")
        print(f"    Load Duration: {load_duration} seconds")
        print(f"    Prompt Eval Duration: {prompt_eval_duration} seconds")
        print(f"    Eval Duration: {eval_duration} seconds")

        print(" ---------------------------- ")

        print(response.message.content)
    else:

        print(f"[-] OCR parsing failed or was incomplete.")
        print(response)


    
    # model='deepseek-ocr:3b' created_at='2025-11-28T11:41:49.792398185Z' 
    # done=True done_reason='stop' total_duration=1831581958 load_duration=107477684 
    # prompt_eval_count=590 prompt_eval_duration=28749886 eval_count=51 eval_duration=1526843938 
    # message=Message(role='assistant', content='...', thinking=None, images=None, tool_name=None, tool_calls=None) 
    # logprobs=None




