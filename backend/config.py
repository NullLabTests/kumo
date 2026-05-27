import os
from dotenv import load_dotenv

load_dotenv()

KUMO_API_KEY = os.getenv("KUMO_API_KEY", "")
HOST = os.getenv("HOST", "0.0.0.0")
PORT = int(os.getenv("PORT", "8080"))

if not KUMO_API_KEY:
    print("WARNING: KUMO_API_KEY not set. Set it in .env file or environment.")
