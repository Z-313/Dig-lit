"""
ETL Pipeline - Extract, Transform, Load
Processes data from various sources for analytics
"""

import json
from pathlib import Path
from typing import Any, Dict, List


class ETLPipeline:
    """Extract, Transform, and Load data for analytics"""

    def __init__(
        self, source_dir: str = "modules/business_intelligence/analytics/logs"
    ):
        self.source_dir = Path(source_dir)

    def extract(self, pattern: str = "*.jsonl") -> List[Dict[str, Any]]:
        """Extract events from log files"""
        events = []
        for log_file in self.source_dir.glob(pattern):
            with open(log_file, "r") as f:
                for line in f:
                    try:
                        events.append(json.loads(line))
                    except json.JSONDecodeError:
                        continue
        return events

    def transform(self, events: List[Dict[str, Any]]) -> Dict[str, Any]:
        """Transform events into aggregated metrics"""
        if not events:
            return {"total": 0}

        metrics = {"total_events": len(events), "event_types": {}, "services": set()}

        for event in events:
            event_type = event.get("type", "unknown")
            metrics["event_types"][event_type] = (
                metrics["event_types"].get(event_type, 0) + 1
            )
            metrics["services"].add(event.get("service", "unknown"))

        metrics["services"] = list(metrics["services"])
        return metrics

    def load(self, metrics: Dict[str, Any], output_file: str = "metrics.json") -> None:
        """Load metrics to storage"""
        output_path = self.source_dir.parent / output_file
        with open(output_path, "w") as f:
            json.dumps(metrics, f, indent=2)
        print(f"[ETL] Metrics saved to {output_path}")

    def run(self) -> Dict[str, Any]:
        """Run full ETL pipeline"""
        print("[ETL] Starting pipeline...")
        events = self.extract()
        metrics = self.transform(events)
        self.load(metrics)
        print("[ETL] Pipeline complete")
        return metrics


if __name__ == "__main__":
    pipeline = ETLPipeline()
    result = pipeline.run()
    print(f"Processed {result['total_events']} events")
