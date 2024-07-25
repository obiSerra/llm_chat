import json
import re
import sys
import requests

from llm_client.logger import Logger
import subprocess


BASE_URL = "http://localhost:11434"
CHAT_URL = f"{BASE_URL}/api/chat"


# assistant_system_prompt = """You are an helpful AI assistant named Bernard.
# If you are asked to search something, your response should have the following format without any deviation or other words:
# EXECUTE_COMMAND: `<search_query>`
# where <search_query> is a valid bash grep command for a Ubuntu system.
# For example, if you are asked to search for the word "hello" in the file "file.txt", your response should be:
# EXECUTE_COMMAND: `grep hello file.txt`
# Answer normally if you are not asked to search for something.
# """


logger = Logger("llm_client_chat")

def make_request(model, messages):
    r = requests.post(
        CHAT_URL, json={"model": model, "messages": messages, "stream": False}
    )
    response = r.json()
    logger.info(response)
    return response


def print_response(content, name):
    print(f"{name}: {content}")


def read_config(config_file):
    with open(config_file, "r") as f:
        config = json.load(f)
    return config


def run_chat(config_file):
    config = read_config(config_file)

    name=config.get("name", "AI")
    model = config["model"]

    system_prompt = config.get("system-prompt", "").format(name=name)

    try:
        r = requests.get(BASE_URL)
        r.raise_for_status()
    except requests.exceptions.RequestException as e:
        print(
            "Could not connect to the chat server. Please make sure the server is running."
        )
        exit(1)

    print(f"Starting {model}...")
    messages = []
    if system_prompt:
        messages.append({"role": "system", "content": system_prompt})

    response = make_request(model, messages)


    try:
        message = response["message"]
    except Exception:
        logger.error(f"Response: {response}")
        print(f"Response: {response}")
        exit(1)
    
    content = message["content"]
    print_response(content, name)
    messages.append(message)

    try:
        while True:
            prompt = input("-> ")

            messages.append({"role": "user", "content": prompt})
            print("...")

            logger.info(f"Before send messages: {messages}")
            response = make_request(model, messages)
            message = response["message"]
            content = message["content"]
            # if content.strip().startswith("EXECUTE_COMMAND:"):
            #     match = re.search(r'`.*`', content)
            #     if match:
            #         cmd = match.group(0).replace("`", "")
            #         print("COMMAND:", cmd)
            #         process = subprocess.Popen(cmd.split(" "), stdout=subprocess.PIPE)
            #         print(process.stdout.read())
            print_response(content, name)

            messages.append(message)

    except KeyboardInterrupt as e:
        print("Quitting now")
        sys.exit(1)
