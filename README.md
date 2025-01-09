## Requirements

- ollama installed (via docker)

## Setup 

- Start both the frontend and backend running

```
bash ./scripts/start.sh
```
and
```
bash ./scripts/start-ui.sh
```

- create a `model.json` file with the list of models you want to pull
- run `bash ./scripts/pull-models.sh` to download all the models