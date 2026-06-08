#!/usr/bin/env python3

import re
from datetime import datetime

import pandas as pd
import folium
from folium.plugins import TimestampedGeoJson


CROWD_FILE = "analysis-0.1e-50reps-300s.txt"
STOPS_FILE = "nodes.csv"
OUTPUT_FILE = "mappa_affollamento_temporale.html"


def load_stops(filename):
    """
    Carica le coordinate delle fermate.
    """

    stops = pd.read_csv(filename, sep=";")

    coords = {}

    for _, row in stops.iterrows():

        stop_id = str(row["stop_I"])

        lat = float(row["lat"])
        lon = float(row["lon"])

        name = str(row["name"])

        coords[stop_id] = (lat, lon, name)

        # variante normalizzata
        coords[stop_id.split("@")[-1].replace("_", "")] = (
            lat,
            lon,
            name,
        )

    return coords


def load_crowd_data(filename, coords):
    """
    Converte il file di affollamento in feature GeoJSON.
    """

    features = []

    current_timestamp = None

    with open(filename, encoding="utf-8") as f:

        for line in f:

            m = re.match(r"\s*After (\d+)s:", line)

            if m:
                current_timestamp = int(m.group(1))
                continue

            m = re.match(
                r"\s*([A-Za-z0-9@_]+):\s*([0-9.]+) people",
                line,
            )

            if not m or current_timestamp is None:
                continue

            stop_id = m.group(1)
            people = float(m.group(2))

            key = stop_id.replace("_", "")

            if key not in coords:
                continue

            lat, lon, name = coords[key]

            local_time = (
                datetime
                .fromtimestamp(current_timestamp)
                .astimezone()
                .strftime("%Y-%m-%d %H:%M:%S")
            )

            radius = max(
                3,
                min(25, people / 40.0)
            )

            features.append(
                {
                    "type": "Feature",
                    "geometry": {
                        "type": "Point",
                        "coordinates": [lon, lat],
                    },
                    "properties": {
                        "time": datetime.fromtimestamp(
                            current_timestamp
                        ).isoformat(),
                        "popup": (
                            f"<b>{name}</b><br>"
                            f"Persone: {people:.1f}<br>"
                            f"Ora locale: {local_time}"
                        ),
                        "icon": "circle",
                        "iconstyle": {
                            "fillColor": "red",
                            "fillOpacity": 0.6,
                            "stroke": False,
                            "radius": radius,
                        },
                    },
                }
            )

    return features


def compute_map_center(coords):
    """
    Calcola il centro della mappa.
    """

    lats = [v[0] for v in coords.values()]
    lons = [v[1] for v in coords.values()]

    return (
        sum(lats) / len(lats),
        sum(lons) / len(lons),
    )


def main():

    coords = load_stops(STOPS_FILE)

    features = load_crowd_data(
        CROWD_FILE,
        coords,
    )

    center_lat, center_lon = compute_map_center(coords)

    m = folium.Map(
        location=[center_lat, center_lon],
        zoom_start=11,
        tiles="CartoDB positron",
    )

    TimestampedGeoJson(
        {
            "type": "FeatureCollection",
            "features": features,
        },
        period="PT10M",
        auto_play=False,
        loop=False,
        max_speed=10,
        loop_button=True,
        date_options="YYYY-MM-DD HH:mm:ss",
        time_slider_drag_update=True,
    ).add_to(m)

    m.save(OUTPUT_FILE)

    print(
        f"Mappa salvata in '{OUTPUT_FILE}' "
        f"({len(features)} punti)"
    )


if __name__ == "__main__":
    main()