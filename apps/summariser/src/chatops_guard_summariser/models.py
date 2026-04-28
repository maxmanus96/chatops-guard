from typing import Literal

from pydantic import BaseModel, Field

Severity = Literal["info", "warning", "error", "critical"]


class Signal(BaseModel):
    source: str = Field(..., min_length=1, max_length=80)
    severity: Severity = "info"
    title: str | None = Field(default=None, max_length=160)
    message: str = Field(..., min_length=1, max_length=4000)
    resource: str | None = Field(default=None, max_length=200)


class SummaryResponse(BaseModel):
    summary: str
    impact: str
    next_action: str
    mode: Literal["rule_based_stub"] = "rule_based_stub"

