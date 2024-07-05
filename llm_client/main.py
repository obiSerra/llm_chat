import re
import sys
import requests

from llm_client.logger import Logger
import subprocess




CHAT_URL = " http://localhost:11434/api/chat"
MODEL = "mistral"


# assistant_system_prompt = """You are an helpful AI assistant named Bernard.
# If you are asked to search something, your response should have the following format without any deviation or other words:
# EXECUTE_COMMAND: `<search_query>`
# where <search_query> is a valid bash grep command for a Ubuntu system.
# For example, if you are asked to search for the word "hello" in the file "file.txt", your response should be:
# EXECUTE_COMMAND: `grep hello file.txt`
# Answer normally if you are not asked to search for something.
# """


assistant_system_prompt = """You are an helpful AI assistant named Bernard."""


def run_chat():

    logger = Logger("llm_client_chat")


    print("Hello from llm_client!")

    messages = [{"role": "system", "content": assistant_system_prompt}]

    try:
        while True:
            prompt = input("-> ")


            messages.append({"role": "user", "content": prompt})
            print("...")

            logger.info(f"Before send messages: {messages}")
            r = requests.post(CHAT_URL, json={"model": MODEL, "messages": messages, "stream": False})
            response = r.json()
            logger.info(response)
            message = response["message"]
            content = message["content"]
            # if content.strip().startswith("EXECUTE_COMMAND:"):
            #     match = re.search(r'`.*`', content)
            #     if match:
            #         cmd = match.group(0).replace("`", "")
            #         print("COMMAND:", cmd)
            #         process = subprocess.Popen(cmd.split(" "), stdout=subprocess.PIPE)
            #         print(process.stdout.read())
            print(f"{MODEL}: {content}")

            messages.append(message)
            
        
    except KeyboardInterrupt as e:
        print("Quitting now")
        sys.exit(1)