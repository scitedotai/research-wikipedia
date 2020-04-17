import xlrd
import csv
import pandas as pd
import numpy as np

df_ssci = pd.read_excel('./wos_raw_data.xlsx', sheet_name='SSCI_collection')
df_scie = pd.read_excel('./wos_raw_data.xlsx', sheet_name='SCIE_collection')

issns = []
def get_issns(df):
  issn_values = df['ISSN'].values
  issn_values = issn_values[~pd.isnull(issn_values)]
  
  e_issn_values = df['eISSN'].values
  e_issn_values = e_issn_values[~pd.isnull(e_issn_values)]

  issns.extend(issn_values)
  issns.extend(e_issn_values)

get_issns(df_scie)
get_issns(df_ssci)
    
with open('wos_issn_output.txt', 'w') as f:
    for item in issns:
        f.write("%s\n" % item.upper())