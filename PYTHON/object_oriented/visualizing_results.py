import os

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import cbsodata
import seaborn as sns


def create_plot(df: pd.DataFrame, y_feat: str, y_label: str) -> plt.Figure:
    # make a plot
    fig, ax = plt.subplots(1, 1)
    x_feat = "lbm"
    df.plot(
        x=x_feat,
        y=y_feat,
        kind="scatter",
        ax=ax
    )

    # add trendline
    z = np.polyfit(df[x_feat], df[y_feat], 1)
    ax.plot(df[x_feat], np.poly1d(z)(df[x_feat]), "r--", lw=1)

    # labels and titles
    ax.set_title("Percentage groen vs leefbaarheid")
    ax.set_xlabel("Leefbaarheidsindex")
    ax.set_ylabel("Aandeel '{}'".format(y_label))

    return fig


if __name__ == "__main__":
    # read the results
    df = pd.read_csv(os.path.join("..", "..", "output", "result.csv"))

    # replace nan with 0
    df = df.fillna(0)

    # read cbs
    cbs_meta = pd.DataFrame(cbsodata.get_meta("84799NED", "DataProperties"))
    cbs = pd.DataFrame(
        cbsodata.get_data(
            '84799NED',
            filters="substringof('BU', WijkenEnBuurten)",
            select=['WijkenEnBuurten', 'Gemeentenaam_1', 'Codering_3', 'GemiddeldeWOZWaardeVanWoningen_35', 'OpleidingsniveauHoog_66', 'GemGestandaardiseerdInkomenVanHuish_75', 'Omgevingsadressendichtheid_116'])
    )

    df = df.merge(
        right=cbs,
        left_on="Buurtcode",
        right_on="Codering_3",
        how="left"
    )

    # temporary save of the merged dataframe
    df.to_csv(os.path.join("..", "..", "output", "temp_out.csv"), index=False)

    # create plots
    for col in ["intense vegetation", "substantial vegetation"]:
        fig = create_plot(df, col, col)
        plt.savefig(os.path.join("..", "..", "output", "scatter_{}.jpg".format(col)))

    # create pair plot
    g = sns.PairGrid(
        df.rename(columns={
                "substantial vegetation": "groenaandeel",
                "lbm": "leefbaarheid",
                "GemiddeldeWOZWaardeVanWoningen_35": "WOZ",
                "Omgevingsadressendichtheid_116": "adressendichtheid"
            }
        ),
        diag_sharey=False,
        corner=True,
        vars=["groenaandeel", "leefbaarheid", "WOZ", "adressendichtheid"]
    )
    g.map_lower(sns.regplot)
    g.map_diag(sns.kdeplot)
    plt.tight_layout()
    plt.savefig(os.path.join("..", "..", "output", "pairs_plot.jpg"))

    plt.show()
    print("finished!")
