#! /usr/bin/env python3

import sqlite3
import pandas as pd
import matplotlib.pyplot as plt
from matplotlib.colors import LogNorm
import seaborn as sns
from datetime import datetime

CONFIG = {
    "readings": 10,
    "palette": "Greens",
    "db": "./var/db.sqlite",
    "date": datetime.now().strftime("%Y-%m-%d")
}

db = sqlite3.connect(CONFIG['db'])

df = pd.read_sql_query("""SELECT common_name, date, location_id, confidence 
                        FROM observation
                        INNER JOIN taxon 
                        ON observation.taxon_id = taxon.taxon_id""", db)
df['date'] = pd.to_datetime(df['date'])
df['hour'] = df['date'].dt.hour
df['date'] = df['date'].dt.date
df['date'] = df['date'].astype(str)
df_on_date = df[df['date'] == CONFIG['date']]
 
top_on_date = (df_on_date['common_name'].value_counts()[:CONFIG['readings']])
if top_on_date.empty:
    print("No observations on {}".format(CONFIG['date']))
    exit()
    
df_top_on_date = df_on_date[df_on_date['common_name'].isin(top_on_date.index)]

# Create a figure with 2 subplots
fig, axs = plt.subplots(1, 2, figsize=(15, 4), gridspec_kw=dict(
    width_ratios=[3, 6]))
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
fig.subplots_adjust(top=0.9)
plt.suptitle(f"Top {CONFIG['readings']} species on {CONFIG['date']}", fontsize=14)
plt.title(f"(Updated on {datetime.now().strftime('%Y/%m-%d %H:%M')})")
plt.savefig(f"./var/charts/chart_{CONFIG['date']}.png", dpi=300)
plt.close()

db.close()