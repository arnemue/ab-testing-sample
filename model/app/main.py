import os
from fastapi import FastAPI

app = FastAPI()

RESPONSE_VAR = os.environ.get("RESPONSE_VAR", default="RED")


@app.get("/")
def read_root():
    return {"prediction": RESPONSE_VAR}
