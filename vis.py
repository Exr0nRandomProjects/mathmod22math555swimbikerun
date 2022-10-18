import pandas as pd
from matplotlib import pyplot as plt

df = pd.read_excel('./HiMCM_TriDataSet.xlsx')

import datetime

epoch = datetime.datetime.utcfromtimestamp(0)

def unix_time_millis(dt):
    print(dt)
    # return (dt - epoch).total_seconds() * 1000.0

data = [unix_time_millis(x) for x in df['BIKE'] if x is not None and not isNan(x)]
print(data[0])

# plt.hist(df['BIKE'])
# plt.show()
#
# print(df)
#
