from chatops_guard_summariser.service import summarise_signal


def test_summarise_signal_uses_severity_specific_guidance() -> None:
    result = summarise_signal(
        {
            "source": "aks",
            "severity": "critical",
            "message": "Node pool is unavailable. Pods cannot be scheduled.",
            "resource": "nodepool/system",
        }
    )

    assert result["summary"] == "aks reported critical: Node pool is unavailable (nodepool/system)"
    assert "immediately" in result["next_action"]
    assert result["mode"] == "rule_based_stub"


def test_summarise_signal_falls_back_to_info_for_unknown_severity() -> None:
    result = summarise_signal(
        {
            "source": "event-grid",
            "severity": "unexpected",
            "message": "Topic received a test event",
        }
    )

    assert result["summary"] == "event-grid reported info: Topic received a test event"
    assert result["impact"] == "Informational signal; no immediate impact is known."

