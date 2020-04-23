# Queries

### Total wiki_data records
```sql
select count(*) from wiki_data;
```
`result: 2002895 (04/17/2020)`

### Total wiki_data records with a doi (not necessarily valid)
```sql
select count(*) from wiki_data where doi is not null;
```
`result: 1923575 (04/17/2020)`

### Total wiki_data records with a valid doi
```sql
select count(*) from doidata inner join wiki_data on doidata.doi = wiki_data.doi;
```
`result: 1880684 (04/17/2020)`

### Total distinct valid wiki_data records with a valid doi
```sql
SELECT COUNT(*) FROM (SELECT DISTINCT doi FROM (
	SELECT doidata.doi as doi FROM doidata INNER JOIN wiki_data ON upper(doidata.doi) = upper(wiki_data.id) WHERE wiki_data.id_type='doi'
) AS b) AS c;
```
`result: 824298 (04/17/2020)`

### Total distinct valid wiki_data records with a record in citation_tallies
```sql
SELECT COUNT(n1.valid_doi)
FROM (SELECT w.id as valid_doi
		FROM wiki_data w
		INNER JOIN doidata d ON d.doi = w.id
		WHERE w.id_type='doi'
		GROUP BY w.id) n1
LEFT JOIN citation_tallies c ON c.doi = n1.valid_doi
WHERE c.doi IS NOT NULL;
```
`results: 676055 (04/17/2020)`


### Get the number of valid_doi from wiki_data that do not have citations

```sql
SELECT COUNT(n1.valid_doi)
FROM (SELECT w.id as valid_doi
		FROM wiki_data w
		INNER JOIN doidata d ON d.doi = w.id
		WHERE w.id_type='doi') n1
LEFT JOIN citations c ON c.target_doi = n1.valid_doi
WHERE c.target_doi IS NULL;
```
`results: 177484 (04/17/2020)`

### Query to get wiki_data we don't have cites for, against citation_tallies

```sql
SELECT COUNT(n1.valid_doi)
FROM (SELECT w.id as valid_doi
		FROM wiki_data w
		INNER JOIN doidata d ON d.doi = w.id
		WHERE w.id_type='doi'
		GROUP BY w.id) n1
LEFT JOIN citation_tallies c ON c.doi = n1.valid_doi
WHERE c.doi IS NULL;
```
`results: 148243 (04/17/2020)`

### Query to get wiki_data we don't have cites for, against citations

```sql
SELECT COUNT(*)
FROM (SELECT DISTINCT valid_doi FROM (SELECT w.id as valid_doi
	FROM wiki_data w
	INNER JOIN doidata d ON d.doi = w.id
	WHERE w.id_type='doi'
	GROUP BY w.id) n1
LEFT JOIN citations c ON c.target_doi = n1.valid_doi WHERE c.target_doi IS NULL) n2;
```
`result: 147213 (04/17/2020)`

### Total number of wiki DOIs we do have citations for, against citation_tallies
```sql
SELECT COUNT(n1.valid_doi)
FROM (SELECT w.id as valid_doi
		FROM wiki_data w
		INNER JOIN doidata d ON d.doi = w.id
		WHERE w.id_type='doi'
		GROUP BY w.id) n1
INNER JOIN citation_tallies c ON c.doi = n1.valid_doi;
```
`result: 676055 (04/17/2020)`

### Total number of wiki DOIs that we do have cites for, against citations

```sql
SELECT COUNT(*) FROM (SELECT DISTINCT valid_doi FROM (SELECT w.id as valid_doi
		FROM wiki_data w
		INNER JOIN doidata d ON d.doi = w.id
		WHERE w.id_type='doi'
		GROUP BY w.id) n1
INNER JOIN citations c ON c.target_doi = n1.valid_doi) n2;
```
`result: 677085 (04/17/2020)`


### General tallies for Wiki cite counts in our system

```sql
SELECT SUM(wiki_total) AS a_wiki_sum_total,
    SUM(wiki_supporting) AS a_wiki_sum_supporting,
    SUM(wiki_contradicting) AS a_wiki_sum_contradicting,
    SUM(wiki_mentioning) AS a_wiki_sum_mentioning,
    SUM(wiki_unclassified) AS a_wiki_sum_unclassified,
    COUNT(*) FILTER(WHERE wiki_mentioning > 0 AND wiki_supporting = 0 AND wiki_contradicting = 0) AS b_wiki_mentioning_only,
    COUNT(*) FILTER(WHERE wiki_supporting > 0 AND wiki_mentioning = 0 AND wiki_contradicting = 0) AS b_wiki_supporting_only, 
    COUNT(*) FILTER(WHERE wiki_contradicting > 0 AND wiki_supporting = 0 AND wiki_mentioning = 0) AS b_wiki_contradicting_only,
    COUNT(*) FILTER(WHERE wiki_contradicting > 0 AND wiki_supporting > 0 AND wiki_mentioning > 0) AS b_wiki_all_tallies,
    COUNT(*) FILTER(WHERE wiki_contradicting > 0 AND wiki_supporting > 0 AND wiki_mentioning = 0) AS b_wiki_contradict_and_support_only,
    COUNT(*) FILTER(WHERE wiki_contradicting > 0 AND wiki_supporting = 0 AND wiki_mentioning > 0) AS b_wiki_contradict_and_mention_only,
    COUNT(*) FILTER(WHERE wiki_contradicting = 0 AND wiki_supporting > 0 AND wiki_mentioning > 0) AS b_wiki_supporting_and_mention_only,
    COUNT(*) FILTER(WHERE wiki_mentioning = 0 AND wiki_supporting = 0 AND wiki_contradicting = 0) AS c_wiki_no_cites,
    COUNT(*) FILTER(WHERE wiki_supporting > 0 AND wiki_mentioning >= 0 AND wiki_contradicting = 0) AS c_wiki_count_support_without_contradict,
    COUNT(*) FILTER(WHERE wiki_contradicting > 0 AND wiki_mentioning >= 0 AND wiki_supporting = 0) AS c_wiki_count_contradict_without_supporting,
    COUNT(*) FILTER(WHERE wiki_supporting > 0 AND wiki_contradicting > 0 AND wiki_mentioning >= 0) AS c_wiki_count_supporting_and_contradicting,
    COUNT(*) FILTER(WHERE wiki_unclassified > 0) AS d_wiki_unclassified_papers,
    COUNT(*) FILTER(WHERE wiki_total = 0) AS d_wiki_no_total
FROM
 (SELECT c.doi,
     SUM(total) AS wiki_total,
     SUM(supporting) AS wiki_supporting,
     SUM(contradicting) AS wiki_contradicting,
     SUM(mentioning) AS wiki_mentioning,
     SUM(unclassified) AS wiki_unclassified
  FROM (SELECT w.id as valid_doi
		FROM wiki_data w
		INNER JOIN doidata d ON d.doi = w.id
		WHERE w.id_type='doi'
		GROUP BY w.id) n1
  INNER JOIN citation_tallies c ON c.doi = n1.valid_doi
  GROUP BY c.doi) t;
```

```json
[
  {
    "a_wiki_sum_unclassified" : 106,
    "b_wiki_mentioning_only" : 324247,
    "b_wiki_contradicting_only" : 98,
    "a_wiki_sum_mentioning" : 51343041,
    "b_wiki_contradict_and_mention_only" : 13954,
    "d_wiki_no_total" : 0,
    "b_wiki_all_tallies" : 102705,
    "d_wiki_unclassified_papers" : 93,
    "c_wiki_no_cites" : 1,
    "b_wiki_contradict_and_support_only" : 14,
    "a_wiki_sum_contradicting" : 214485,
    "a_wiki_sum_supporting" : 1694168,
    "c_wiki_count_support_without_contradict" : 235036,
    "c_wiki_count_supporting_and_contradicting" : 102719,
    "b_wiki_supporting_only" : 814,
    "b_wiki_supporting_and_mention_only" : 234222,
    "c_wiki_count_contradict_without_supporting" : 14052,
    "a_wiki_sum_total" : 53251800
  }
]
```