## How to run CV server ?
1. First set environment variable `AZURE_COMPUTER_VISION_KEY` (inbox me to get it)
2. Create virtual environment

```bash
python3 -m venv venv
```

3. Install dependencies in `requirements.txt`

```bash
pip install -r requirements.txt 
```

4. Locate to directory `api` and run CV server

```bash 
uvicorn wrapper:app --reload
```

