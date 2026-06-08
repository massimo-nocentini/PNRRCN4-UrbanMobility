
import re
from datetime import datetime

import pandas as pd
import folium

# ---------------------------------------------------------------------
# CONFIGURAZIONE
# ---------------------------------------------------------------------

CROWD_FILE = "analysis-0.1e-50reps-300s.txt"
STOPS_FILE = "nodes.csv"
OUTPUT_FILE = "mappa_picco_affollamento.html"

# ---------------------------------------------------------------------
# CARICAMENTO COORDINATE FERMATE
# ---------------------------------------------------------------------

stops = pd.read_csv(STOPS_FILE, sep=";")

coords = {}

for _, row in stops.iterrows():
    stop_id = str(row["stop_I"])

    coords[stop_id] = {
        "lat": float(row["lat"]),
        "lon": float(row["lon"]),
        "name": str(row["name"]),
    }

    # variante senza prefisso "6@" / "7@" ecc.
    short_id = stop_id.split("@")[-1]
    coords[short_id] = coords[stop_id]

    # variante senza underscore
    coords[short_id.replace("_", "")] = coords[stop_id]

# ---------------------------------------------------------------------
# PARSING DEI DATI DI AFFOLLAMENTO
# ---------------------------------------------------------------------

snapshots = {}

current_timestamp = None

with open(CROWD_FILE, "r", encoding="utf-8") as f:
    for line in f:

        match = re.match(r"\s*After (\d+)s:", line)

        if match:
            current_timestamp = int(match.group(1))
            snapshots[current_timestamp] = []
            continue

        match = re.match(
            r"\s*([A-Za-z0-9@_]+):\s*([0-9.]+) people",
            line,
        )

        if match and current_timestamp is not None:
            stop_id = match.group(1)
            people = float(match.group(2))

            snapshots[current_timestamp].append(
                (stop_id, people)
            )

# ---------------------------------------------------------------------
# TROVA IL MOMENTO DI PICCO
# ---------------------------------------------------------------------

peak_timestamp = None
peak_total_people = -1

for timestamp, records in snapshots.items():

    total_people = sum(
        people
        for _, people in records
    )

    if total_people > peak_total_people:
        peak_total_people = total_people
        peak_timestamp = timestamp

print("Picco trovato:")
print(
    datetime.fromtimestamp(peak_timestamp)
)

print(
    f"Totale persone: {peak_total_people:,.1f}"
)

# ---------------------------------------------------------------------
# CREA LA MAPPA
# ---------------------------------------------------------------------

m = folium.Map(
    location=[43.77, 11.25],
    zoom_start=11,
    tiles="CartoDB Positron",
)

records = snapshots[peak_timestamp]

for stop_id, people in records:

    key = stop_id.replace("_", "")

    if key not in coords:
        continue

    stop = coords[key]

    radius = max(
        3,
        min(30, people / 30),
    )

    popup = f"""
    <b>{stop['name']}</b><br>
    Affollamento: {people:.1f}<br>
    Ora: {datetime.fromtimestamp(peak_timestamp)}
    """

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

print()
print(f"Mappa salvata in: {OUTPUT_FILE}")