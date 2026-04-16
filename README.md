# Ollama Scripts

A collection of bash scripts for managing and interacting with Ollama models.

## Scripts

- **benchmark-model.sh** - Benchmark an Ollama model's performance. Requires the model name as an argument. Accepts an optional custom prompt for benchmarking.
- **chat.sh** - Start an interactive chat session with an Ollama model. Defaults to `llama3.2:1b` if no model is specified.
- **install-model.sh** - Download and install a model from ollama.com. Requires the model name as an argument.
- **list-models.sh** - Display all installed Ollama models with their sizes.
- **remove-model.sh** - Delete an installed model. Requires the model name as an argument.

## Requirements

- [Ollama](https://ollama.ai) installed and running locally on `http://localhost:11434`
- `bash`, `curl`, and `bc` for script execution

## Quick Start

1. Install a model:
   ```bash
   ./scripts/install-model.sh llama3.2:1b
   ```

2. Start chatting:
   ```bash
   ./scripts/chat.sh
   ```

3. View installed models:
   ```bash
   ./scripts/list-models.sh
   ```

4. Benchmark a model:
   ```bash
   ./scripts/benchmark-model.sh llama3.2:1b
   ```

5. Remove a model:
   ```bash
   ./scripts/remove-model.sh llama3.2:1b
   ```
