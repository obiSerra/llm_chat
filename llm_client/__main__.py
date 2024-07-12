from llm_client.main import run_chat
import argparse


def parse_ops():
    parser = argparse.ArgumentParser(description="Run the chat client.")
    parser.add_argument("--config", type=str, help="Path to the config file.")

    return parser.parse_args()

if __name__ == "__main__":

    args = parse_ops()
    run_chat(config_file=args.config)