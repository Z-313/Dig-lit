"""
Analytics Tracker - Event logging and metrics collection
Integrates with BI dashboard for real-time monitoring
"""

import json
from datetime import datetime
from pathlib import Path
from typing import Any, Dict

LOG_DIR = Path("modules/business_intelligence/analytics/logs")
LOG_DIR.mkdir(parents=True, exist_ok=True)


class AnalyticsTracker:
    """Track events and metrics across the Dig|lit platform"""

    def __init__(self, service_name: str = "diglit"):
        self.service_name = service_name
        self.log_file = LOG_DIR / f"{service_name}_events.jsonl"

    def track(self, event_type: str, data: Dict[str, Any]) -> None:
        """Log an event with timestamp and metadata"""
        event = {
            "timestamp": datetime.utcnow().isoformat(),
            "service": self.service_name,
            "type": event_type,
            "data": data,
        }

        with open(self.log_file, "a") as f:
            f.write(json.dumps(event) + "\n")

        print(f"[BI] Event tracked: {event_type}")

    def get_metrics(self) -> Dict[str, Any]:
        """Get aggregated metrics"""
        if not self.log_file.exists():
            return {"total_events": 0}

        event_count = sum(1 for _ in open(self.log_file))
        return {
            "total_events": event_count,
            "log_file": str(self.log_file),
            "service": self.service_name,
        }


# Global tracker instance
tracker = AnalyticsTracker()


def track(event_type: str, data: Dict[str, Any]) -> None:
    """Convenience function for tracking events"""
    tracker.track(event_type, data)


if __name__ == "__main__":
    track("ai_inference", {"model": "gpt-4o-mini", "tokens": 150})
    track("voice_interaction", {"duration": 3.5, "language": "en"})
    print(tracker.get_metrics())
