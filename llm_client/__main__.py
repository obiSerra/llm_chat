from llm_client.main import run_chat, run_completion
import argparse


def parse_ops():
    parser = argparse.ArgumentParser(description="Run the chat client.")
    parser.add_argument("--config", type=str, help="Path to the config file.")
    parser.add_argument("--task", type=str, default='chat', help="Chat or completion.")
    parser.add_argument("--prompt", type=str, default=None, help="Prompt for completion.")

    return parser.parse_args()

if __name__ == "__main__":

    args = parse_ops()

    if args.task == 'chat':
        run_chat(config_file=args.config)
    else:
        run_completion(config_file=args.config, prompt=args.prompt)