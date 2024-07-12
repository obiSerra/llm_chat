## Requirements

- ollama installed (via docker)

## Setup 

- Create and activate a `venv`
- Run `$ pip install -r requirements.txt`
- Run `$ pip install -e .`
- Create an `.env` file using the `env-SAMPLE` as model
- Fetch the models using `scripts/pull-models.sh`


## Run

Run `$ bash chat.sh`

or use a specific configuration with 
`$ bash chat.sh --config <config-file-name>`

eg:

`$ bash chat.sh --config hal9001` if you have a `hal9001.json` config file in the project root
