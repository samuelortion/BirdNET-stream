#! /usr/bin/env python3

import sqlite3
import pandas as pd
import matplotlib.pyplot as plt
from matplotlib.colors import LogNorm
import seaborn as sns
from datetime import datetime
import os
import glob

CONFIG = {
    "readings": 10,
    "palette": "Greens",
    "db": "./var/db.sqlite",
    "date": datetime.now().strftime("%Y-%m-%d"),
    "charts_dir": "./var/charts"
}

db = None

def get_database():
    global db
    if db is None:
        db = sqlite3.connect(CONFIG["db"])
    return db
    
def chart(date):
    db  = get_database()
    df = pd.read_sql_query(f"""SELECT common_name, date, location_id, confidence 
                            FROM observation
                            INNER JOIN taxon 
                            ON observation.taxon_id = taxon.taxon_id 
                            WHERE STRFTIME("%Y-%m-%d", `date`) = '{date}'""", db)
    df['date'] = pd.to_datetime(df['date'])
    df['hour'] = df['date'].dt.hour
    df['date'] = df['date'].dt.date
    df['date'] = df['date'].astype(str)
    df_on_date = df[df['date'] == date]
    
    top_on_date = (df_on_date['common_name'].value_counts()[:CONFIG['readings']])
    if top_on_date.empty:
        print("No observations on {}".format(date))
        return
    else:
        print(f"Found observations on {date}")
        
    df_top_on_date = df_on_date[df_on_date['common_name'].isin(top_on_date.index)]

    # Create a figure with 2 subplots
    fig, axs = plt.subplots(1, 2, figsize=(20, 5), gridspec_kw=dict(
        width_ratios=[2, 6]))
    plt.subplots_adjust(left=None, bottom=None, right=None,
                        top=None, wspace=0, hspace=0)

    # Get species frequencies
    frequencies_order = pd.value_counts(df_top_on_date['common_name']).iloc[:CONFIG['readings']].index
    # Get min max confidences
    confidence_minmax = df_top_on_date.groupby('common_name')['confidence'].max()
    confidence_minmax = confidence_minmax.reindex(frequencies_order)
    # Norm values for color palette
    norm = plt.Normalize(confidence_minmax.values.min(),
                            confidence_minmax.values.max())

    colors = plt.cm.Greens(norm(confidence_minmax))
    plot = sns.countplot(y='common_name', data=df_top_on_date, palette=colors, order=frequencies_order, ax=axs[0])

    plot.set(ylabel=None)
    plot.set(xlabel="Detections")

    heat = pd.crosstab(df_top_on_date['common_name'], df_top_on_date['hour'])
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
        yticklabels=False)
    plot.set_xticklabels(plot.get_xticklabels(), rotation=0, size=7)

    for _, spine in plot.spines.items():
        spine.set_visible(True)

    plot.set(ylabel=None)
    plot.set(xlabel="Hour of day")
    plt.suptitle(f"Top {CONFIG['readings']} species on {date}", fontsize=14)
    plt.text(15, 11, f"(Updated on {datetime.now().strftime('%Y/%m-%d %H:%M')})")
    plt.savefig(f"./var/charts/chart_{date}.png", dpi=300)
    print(f"Plot for {date} saved.")
    plt.close()

def main():
    done_charts = glob.glob(f"{CONFIG['charts_dir']}/*.png")
    last_modified = max(done_charts, key=os.path.getctime)
    last_modified_date = last_modified.split("_")[-1].split(".")[0]
    missing_dates = pd.date_range(start=last_modified_date, end=CONFIG['date'], freq='D')
    print(missing_dates)
    for missing_date in missing_dates:
        date = missing_date.strftime("%Y-%m-%d")
        chart(date)
    chart(CONFIG['date'])
    if db is not None:
        db.close()
    print("Done.")

if __name__ == "__main__":
    main()