#! /usr/bin/env python3

from curses import def_prog_mode
import sqlite3
from xml.sax.handler import feature_external_ges
import pandas as pd
import matplotlib.pyplot as plt
from matplotlib.colors import LogNorm
import seaborn as sns
from datetime import datetime

CONFIG = {
    "readings": 10,
    "palette": "Greens",
}

db = None
def get_database():
    global db
    if db is None:
        db = sqlite3.connect('/home/ortion/Desktop/db.sqlite')
    return db


def get_detection_hourly(date):
    db = get_database()
    df = pd.read_sql_query("""SELECT common_name, date, location_id, confidence 
                            FROM observation
                            INNER JOIN taxon 
                            ON observation.taxon_id = taxon.taxon_id""", db)

    df['date'] = pd.to_datetime(df['date'])
    df['hour'] = df['date'].dt.hour
    df['date'] = df['date'].dt.date
    df['date'] = df['date'].astype(str)

    df_on_date = df[df['date'] == date]
    return df_on_date


def get_top_species(df, limit=10):
    return df['common_name'].value_counts()[:CONFIG['readings']]


def get_top_detections(df, limit=10):
    df_top_species = get_top_species(df, limit=limit)
    return df[df['common_name'].isin(df_top_species.index)]


def get_frequence_order(df, limit=10):
    pd.value_counts(df['common_name']).iloc[:limit]

def presence_chart(date, filename):
    df_detections = get_detection_hourly(date)
    df_top_detections = get_top_detections(df_detections, limit=CONFIG['readings'])
    fig, axs = plt.subplots(1, 2, figsize=(15, 4), gridspec_kw=dict(
        width_ratios=[3, 6]))
    plt.subplots_adjust(left=None, bottom=None, right=None,
                        top=None, wspace=0, hspace=0)

    frequencies_order = get_frequence_order(df_detections, limit=CONFIG["readings"])
    # Get min max confidences
    confidence_minmax = df_detections.groupby('common_name')['confidence'].max()
    # Norm values for color palette
    norm = plt.Normalize(confidence_minmax.values.min(),
                         confidence_minmax.values.max())
    colors = plt.cm.Greens(norm(confidence_minmax))
    plot = sns.countplot(y='common_name', data=df_top_detections, palette=colors, order=frequencies_order, ax=axs[0])

    plot.set(ylabel=None)
    plot.set(xlabel="Detections")

    heat = pd.crosstab(df_top_detections['common_name'], df_top_detections['hour'])
    # Order heatmap Birds by frequency of occurrance
    heat.index = pd.CategoricalIndex(heat.index, categories=frequencies_order)
    heat.sort_index(level=0, inplace=True)

    hours_in_day = pd.Series(data=range(0, 24))
    heat_frame = pd.DataFrame(data=0, index=heat.index, columns=hours_in_day)
    heat = (heat + heat_frame).fillna(0)

    # Generate heatmap plot
    plot = sns.heatmap(
        heat,
        norm=LogNorm(),
        annot=True,
        annot_kws={
            "fontsize": 7
        },
        fmt="g",
        cmap=CONFIG['palette'],
        square=False,
        cbar=False,
        linewidth=0.5,
        linecolor="Grey",
        ax=axs[1],
        yticklabels=False
    )
    plot.set_xticklabels(plot.get_xticklabels(), rotation=0, size=7)
    
    for _, spine in plot.spines.items():
        spine.set_visible(True)

    plot.set(ylabel=None)
    plot.set(xlabel="Hour of day")
    fig.subplots_adjust(top=0.9)
    plt.suptitle(f"Top {CONFIG['readings']} species (Updated on {datetime.now().strftime('%Y/%m-%d %H:%M')})")

    plt.savefig(filename)
    plt.close()

def main():
    date = datetime.now().strftime('%Y%m%d')
    presence_chart(date, f'./var/charts/chart_{date}.png')
    # print(get_top_detections(get_detection_hourly(date), limit=10))
    if not db is None:
        db.close()

if __name__ == "__main__":
    main()
