# /// script
# dependencies = [
#  'requests',
# ]
# ///

import requests

# from ollama import Client
base_url = "http://localhost:11434"


def list_models():
    response = requests.get(f"{base_url}/api/tags")
    response.raise_for_status()
    return response.json().get("models", [])

def print_model_list():
    models = list_models()
    for model in models:
        print(
            f"- {model.get('name')} - {model.get('details', {}).get('parameter_size')}"
        )



if __name__ == "__main__":
    print_model_list()
