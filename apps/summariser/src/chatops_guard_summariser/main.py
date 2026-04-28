from fastapi import FastAPI

from .models import Signal, SummaryResponse
from .service import summarise_signal

app = FastAPI(
    title="ChatOps Guard Summariser",
    version="0.1.0",
    description="Turns raw operational signals into short operator-facing summaries.",
)


@app.get("/healthz")
def healthz() -> dict[str, str]:
    return {"status": "ok", "service": "summariser"}


@app.post("/summarise", response_model=SummaryResponse)
def summarise(signal: Signal) -> SummaryResponse:
    return SummaryResponse(**summarise_signal(signal.model_dump()))

