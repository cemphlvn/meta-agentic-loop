#!/usr/bin/env python3
"""
Playground Metrics Calculator
Calculates dashboard metrics from system state files.
"""
import json
import re
import sys
from datetime import datetime, timedelta
from pathlib import Path
from collections import defaultdict


def parse_remembrance(path: Path) -> dict:
    """Parse .remembrance for agent activity and truths."""
    agents = defaultdict(int)
    shape_shifts = []

    if not path.exists():
        return {"agents": {}, "shape_shifts": [], "total_truths": 0}

    content = path.read_text()
    blocks = content.split("---")

    for block in blocks:
        if not block.strip():
            continue

        # Extract agent
        agent_match = re.search(r'agent:\s*(\S+)', block)
        if agent_match:
            agents[agent_match.group(1)] += 1

        # Check for shape_shift
        if 'shape_shift: true' in block:
            truth_match = re.search(r'truth:\s*(.+?)(?:\n|$)', block)
            if truth_match:
                shape_shifts.append(truth_match.group(1).strip())

    return {
        "agents": dict(agents),
        "shape_shifts": shape_shifts,
        "total_truths": sum(agents.values())
    }


def parse_evolution(path: Path) -> dict:
    """Parse EVOLUTION.md for timeline events."""
    events = []

    if not path.exists():
        return {"events": [], "compliance_history": []}

    content = path.read_text()

    # Extract compliance progression
    compliance = []
    for match in re.finditer(r'(\d{4}-\d{2}-\d{2}).*?(\d+)%', content):
        compliance.append({
            "date": match.group(1),
            "score": int(match.group(2))
        })

    # Extract hidden occurrences
    in_table = False
    for line in content.split('\n'):
        if '| Timestamp |' in line:
            in_table = True
            continue
        if in_table and line.startswith('|') and '---' not in line:
            parts = [p.strip() for p in line.split('|')[1:-1]]
            if len(parts) >= 4:
                events.append({
                    "timestamp": parts[0],
                    "event": parts[1],
                    "agent": parts[2],
                    "ticket": parts[3]
                })

    return {
        "events": events[-20:],  # Last 20 events
        "compliance_history": compliance
    }


def parse_roadmap(path: Path) -> dict:
    """Parse ROADMAP.md for DUE dates and progress."""
    items = []
    milestones = []

    if not path.exists():
        return {"items": [], "milestones": [], "overdue": []}

    content = path.read_text()
    today = datetime.now().strftime("%Y-%m-%d")

    # Parse DUE dates table
    in_table = False
    for line in content.split('\n'):
        if '| ID |' in line and '| DUE |' in line:
            in_table = True
            continue
        if in_table and line.startswith('|') and '---' not in line:
            parts = [p.strip() for p in line.split('|')[1:-1]]
            if len(parts) >= 5:
                items.append({
                    "id": parts[0],
                    "title": parts[1],
                    "start": parts[2],
                    "due": parts[3],
                    "status": parts[4]
                })

    # Find overdue
    overdue = [i for i in items if i["due"] < today and i["status"] not in ["DONE", "Done"]]

    # Parse milestones
    in_milestones = False
    for line in content.split('\n'):
        if '| Milestone |' in line:
            in_milestones = True
            continue
        if in_milestones and line.startswith('|') and '---' not in line:
            parts = [p.strip() for p in line.split('|')[1:-1]]
            if len(parts) >= 2:
                milestones.append({
                    "name": parts[0],
                    "date": parts[1]
                })

    return {
        "items": items,
        "milestones": milestones,
        "overdue": overdue
    }


def main():
    project_root = Path(sys.argv[1]) if len(sys.argv) > 1 else Path.cwd()

    remembrance = parse_remembrance(project_root / ".remembrance")
    evolution = parse_evolution(project_root / "scrum" / "EVOLUTION.md")
    roadmap = parse_roadmap(project_root / "scrum" / "ROADMAP.md")

    metrics = {
        "timestamp": datetime.utcnow().isoformat(),
        "agent_activity": remembrance["agents"],
        "total_truths": remembrance["total_truths"],
        "shape_shifts": remembrance["shape_shifts"],
        "compliance_history": evolution["compliance_history"],
        "recent_events": evolution["events"],
        "roadmap_items": len(roadmap["items"]),
        "overdue_items": roadmap["overdue"],
        "milestones": roadmap["milestones"]
    }

    print(json.dumps(metrics, indent=2))


if __name__ == "__main__":
    main()
