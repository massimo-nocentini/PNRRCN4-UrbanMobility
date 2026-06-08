import re
from datetime import datetime, time

import pandas as pd
import folium

# ---------------------------------------------------------------------
# CONFIGURAZIONE
# ---------------------------------------------------------------------

CROWD_FILE = "analysis-0.1e-50reps-300s.txt"
STOPS_FILE = "nodes.csv"
OUTPUT_FILE = "mappa_ore_10.html"

# ---------------------------------------------------------------------
# CARICAMENTO FERMATE
# ---------------------------------------------------------------------

stops = pd.read_csv(STOPS_FILE, sep=";")

coords = {}

for _, row in stops.iterrows():

    stop_id = str(row["stop_I"])

    data = {
        "lat": float(row["lat"]),
        "lon": float(row["lon"]),
        "name": str(row["name"]),
    }

    coords[stop_id] = data

    short_id = stop_id.split("@")[-1]

    coords[short_id] = data
    coords[short_id.replace("_", "")] = data

# ---------------------------------------------------------------------
# LETTURA SNAPSHOTS
# ---------------------------------------------------------------------

snapshots = {}

current_ts = None

with open(CROWD_FILE, encoding="utf-8") as f:

    for line in f:

        m = re.match(r"\s*After (\d+)s:", line)

        if m:
            current_ts = int(m.group(1))
            snapshots[current_ts] = []
            continue

        m = re.match(
            r"\s*([A-Za-z0-9@_]+):\s*([0-9.]+) people",
            line,
        )

        if m and current_ts is not None:

            stop_id = m.group(1)
            people = float(m.group(2))

            snapshots[current_ts].append(
                (stop_id, people)
            )

# ---------------------------------------------------------------------
# TROVA LO SNAPSHOT PIÙ VICINO ALLE 10:00
# ---------------------------------------------------------------------

target_hour = 10
target_minute = 0

best_ts = None
best_distance = None

for ts in snapshots:

    dt = datetime.fromtimestamp(ts)

    target_dt = dt.replace(
        hour=target_hour,
        minute=target_minute,
        second=0,
        microsecond=0,
    )

    distance = abs((dt - target_dt).total_seconds())

    if best_distance is None or distance < best_distance:
        best_distance = distance
        best_ts = ts

selected_time = datetime.fromtimestamp(best_ts)

print("Snapshot selezionato:")
print(selected_time)

# ---------------------------------------------------------------------
# CREA MAPPA
# ---------------------------------------------------------------------

m = folium.Map(
    location=[43.77, 11.25],
    zoom_start=11,
    tiles="CartoDB Positron",
)

for stop_id, people in snapshots[best_ts]:

    key = stop_id.replace("_", "")

    if key not in coords:
        continue

    stop = coords[key]

    radius = max(
        3,
        min(30, people / 30),
    )

    popup = (
        f"<b>{stop['name']}</b><br>"
        f"Persone: {people:.1f}<br>"
        f"Ora: {selected_time}"
    )

    folium.CircleMarker(
        location=[stop["lat"], stop["lon"]],
        radius=radius,
        color="red",
        fill=True,
        fill_opacity=0.6,
        popup=popup,
    ).add_to(m)

# ---------------------------------------------------------------------
# SALVA
# ---------------------------------------------------------------------

m.save(OUTPUT_FILE)

print(f"Mappa salvata in {OUTPUT_FILE}")