import sys
import requests

from llm_client.logger import Logger




CHAT_URL = " http://localhost:11434/api/chat"
MODEL = "mistral"



def run_chat():

    logger = Logger("llm_client_chat")


    print("Hello from llm_client!")

    messages = []

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
            print(f"{MODEL}: {message["content"]}")

            messages.append(message)
            
        
    except KeyboardInterrupt as e:
        print("Quitting now")
        sys.exit(1)