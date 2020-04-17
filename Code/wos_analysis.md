# Setup

### Get ISSNs

```sh
python get_wos_issns.py
```

### Load file to DB (tmp table)
```
cat issn_output.txt | psql -h scite-db.scite.ai -p 5432 catalog -c "COPY wos_issn_tmp FROM STDIN WITH (FORMAT CSV);" -U scite
```

### Load distinct records into main table
```sql
INSERT INTO public.wos_issn
SELECT DISTINCT ON (issn) *
FROM public.wos_issn_tmp
ORDER BY issn;
```

### Verify no dupes
```sql
SELECT issn, count(*) FROM public.wos_issn
GROUP BY issn HAVING count(*) > 1;
```

### Make materialized view
```sql
CREATE MATERIALIZED VIEW wos_doi_data AS SELECT doidata.doi
  FROM wos_issn
    JOIN doidata ON wos_issn.issn::text = ANY (doidata.issn_array::text[])
GROUP BY doidata.doi
WITH NO DATA;
```

### Refresh the materialized view


# Queries

_Note that these are definitionally WoS DOIs (and valid) that we have in our system
since this is already joined on doidata_

### Total number of WoS DOIs that we have
```sql
SELECT COUNT(*) FROM wos_doi_data;
```
`result: 51804643 (04/17/2020)`

### Total number of WoS DOIs we have citation_tallies for
```sql
SELECT COUNT(*)
FROM citation_tallies
INNER JOIN wos_doi_data ON citation_tallies.doi = wos_doi_data.doi;
```
`result: 25408633 (04/17/2020)`

### Total number of WoS DOIs that we don't have cites for, against citations
```sql
SELECT COUNT(wos_doi_data.doi)
FROM wos_doi_data
LEFT JOIN citations c ON c.target_doi = wos_doi_data.doi
WHERE c.target_doi IS NULL;
```
`result: 26311090 (04/17/2020)`

### Total number of WoS DOIs that we don't have cites for, against citation_tallies

```sql
SELECT COUNT(wos_doi_data.doi)
FROM wos_doi_data
LEFT JOIN citation_tallies c ON c.doi = wos_doi_data.doi
WHERE c.doi IS NULL;
```
`result: 26396010 (04/17/2020)`

### Total number of WoS DOIs that we do have cites for, against citation_tallies

```sql
SELECT COUNT(w.doi)
FROM wos_doi_data w
INNER JOIN citation_tallies c ON c.doi = w.doi;
```
`result: 25408633 (04/17/2020)`

### Total number of WoS DOIs that we do have cites for, against citations

```sql
SELECT COUNT(w.doi)
FROM wos_doi_data w
INNER JOIN citations c ON c.target_doi = w.doi;
```
`result: 433830303 (04/17/2020)`

### General tallies for wiki cite counts in our system

```sql
SELECT SUM(wos_total) AS wos_sum_total,
    SUM(wos_supporting) AS wos_sum_supporting,
    SUM(wos_contradicting) AS wos_sum_contradicting,
    SUM(wos_mentioning) AS wos_sum_mentioning,
    SUM(wos_unclassified) AS wos_sum_unclassified,
    COUNT(*) FILTER(WHERE wos_contradicting > 0 AND wos_supporting = 0) AS wos_count_contradict_without_supporting,
    COUNT(*) FILTER(WHERE wos_supporting > 0 AND wos_contradicting = 0) AS wos_count_support_without_contradict,
    COUNT(*) FILTER(WHERE wos_supporting > 0 AND wos_contradicting > 0) AS wos_count_supporting_and_contradicting,
    COUNT(*) FILTER(WHERE wos_supporting = 0 AND wos_contradicting = 0) AS wos_count_no_supporting_or_contradicting
FROM
 (SELECT w.doi,
     SUM(total) AS wos_total,
     SUM(supporting) AS wos_supporting,
     SUM(contradicting) AS wos_contradicting,
     SUM(mentioning) AS wos_mentioning,
     SUM(unclassified) AS wos_unclassified
  FROM wos_doi_data w
  INNER JOIN citation_tallies c ON c.doi = w.doi
  GROUP BY w.doi) t;
```
result: (04/17/2020)

```
[
  {
    "wos_sum_contradicting" : 2710605,
    "wos_sum_total" : 429781265,
    "wos_count_no_supporting_or_contradicting" : 17441586,
    "wos_sum_mentioning" : 408129332,
    "wos_count_contradict_without_supporting" : 521024,
    "wos_sum_supporting" : 18940149,
    "wos_count_supporting_and_contradicting" : 1407829,
    "wos_sum_unclassified" : 1179,
    "wos_count_support_without_contradict" : 6038194
  }
]
```


### General tallies for wiki cite counts in our system (for Nature Commentary
report)

```sql
SELECT citation_tallies.doi, supporting, contradicting, mentioning, unclassified
FROM citation_tallies
INNER JOIN wos_doi_data
ON citation_tallies.doi = wos_doi_data.doi;
```
`wos_doi_tallies.csv` (on google drive)

### Get retracted

```sql
SELECT wos_doi_data.doi, doidata.retracted
FROM doidata 
INNER JOIN wos_doi_data
ON doidata.doi = wos_doi_data.doi
WHERE doidata.retracted = true;
```
`wos_retracted.csv`