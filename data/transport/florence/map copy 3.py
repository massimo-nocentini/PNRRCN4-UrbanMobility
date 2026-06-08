import re
from collections import defaultdict
from datetime import datetime

import pandas as pd
import folium

# ---------------------------------------------------------------------
# CONFIGURAZIONE
# ---------------------------------------------------------------------

CROWD_FILE = "analysis-0.1e-50reps-300s.txt"
STOPS_FILE = "nodes.csv"
OUTPUT_FILE = "mappa_cumulata_fino_10.html"

TARGET_HOUR = 10
TARGET_MINUTE = 0

# ---------------------------------------------------------------------
# CARICAMENTO FERMATE
# ---------------------------------------------------------------------

stops = pd.read_csv(STOPS_FILE, sep=";")

coords = {}

for _, row in stops.iterrows():

    stop_id = str(row["stop_I"])

    info = {
        "lat": float(row["lat"]),
        "lon": float(row["lon"]),
        "name": str(row["name"]),
    }

    coords[stop_id] = info

    short = stop_id.split("@")[-1]

    coords[short] = info
    coords[short.replace("_", "")] = info

# ---------------------------------------------------------------------
# LETTURA SNAPSHOT
# ---------------------------------------------------------------------

snapshots = {}

current_ts = None

with open(CROWD_FILE, encoding="utf8") as f:

    for line in f:

        m = re.match(r"\s*After (\d+)s:", line)

        if m:
            current_ts = int(m.group(1))
            snapshots[current_ts] = []
            continue

        m = re.match(
            r"\s*([A-Za-z0-9@_]+):\s*([0-9.]+) people",
            line
        )

        if m and current_ts is not None:

            stop_id = m.group(1)
            people = float(m.group(2))

            snapshots[current_ts].append(
                (stop_id, people)
            )

# ---------------------------------------------------------------------
# SELEZIONA SNAPSHOT <= 10:00
# ---------------------------------------------------------------------

cumulative = defaultdict(float)

used_snapshots = 0

for ts, records in snapshots.items():

    dt = datetime.fromtimestamp(ts)

    if (
        dt.hour < TARGET_HOUR
        or (
            dt.hour == TARGET_HOUR
            and dt.minute <= TARGET_MINUTE
        )
    ):

        used_snapshots += 1

        for stop_id, people in records:
            cumulative[stop_id] += people

print(f"Snapshot utilizzati: {used_snapshots}")

# ---------------------------------------------------------------------
# CREA MAPPA
# ---------------------------------------------------------------------

m = folium.Map(
    location=[43.77, 11.25],
    zoom_start=11,
    tiles="CartoDB Positron"
)

max_value = max(cumulative.values())

for stop_id, total_people in cumulative.items():

    key = stop_id.replace("_", "")

    if key not in coords:
        continue

    stop = coords[key]

    radius = 4 + 25 * total_people / max_value

    popup = f"""
    <b>{stop['name']}</b><br>
    Persone cumulative: {total_people:.0f}
    """

    folium.CircleMarker(
        location=[stop["lat"], stop["lon"]],
        radius=radius,
        color="red",
        fill=True,
        fill_opacity=0.6,
        popup=popup
    ).add_to(m)

m.save(OUTPUT_FILE)

print("Mappa salvata:", OUTPUT_FILE)