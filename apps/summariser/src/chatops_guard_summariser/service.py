from collections.abc import Mapping
from typing import Any

IMPACT_BY_SEVERITY = {
    "critical": "User-facing or automation-impacting failure is likely.",
    "error": "A component may be failing and needs operator attention.",
    "warning": "The system may be degraded or close to an operational threshold.",
    "info": "Informational signal; no immediate impact is known.",
}

NEXT_ACTION_BY_SEVERITY = {
    "critical": "Check the affected resource immediately and prepare rollback or mitigation.",
    "error": "Inspect recent logs, deployment changes, and resource health.",
    "warning": "Watch the signal and check configuration before it becomes an incident.",
    "info": "Record the signal and continue monitoring.",
}


def summarise_signal(signal: Mapping[str, Any]) -> dict[str, str]:
    source = _clean(signal.get("source")) or "unknown-source"
    severity = (_clean(signal.get("severity")) or "info").lower()
    title = _clean(signal.get("title"))
    message = _clean(signal.get("message")) or "No message supplied."
    resource = _clean(signal.get("resource"))

    if severity not in IMPACT_BY_SEVERITY:
        severity = "info"

    headline = title or _first_sentence(message)
    summary = f"{source} reported {severity}: {headline}"
    if resource:
        summary = f"{summary} ({resource})"

    return {
        "summary": _shorten(summary, 240),
        "impact": IMPACT_BY_SEVERITY[severity],
        "next_action": NEXT_ACTION_BY_SEVERITY[severity],
        "mode": "rule_based_stub",
    }


def _clean(value: Any) -> str:
    if value is None:
        return ""
    return " ".join(str(value).split())


def _first_sentence(message: str) -> str:
    for separator in (".", "!", "?"):
        if separator in message:
            return message.split(separator, 1)[0]
    return message


def _shorten(value: str, limit: int) -> str:
    if len(value) <= limit:
        return value
    return f"{value[: limit - 1].rstrip()}…"

