SELECT wiki_data.page_id, citation_tallies.doi, supporting, contradicting, mentioning, unclassified
FROM citation_tallies
INNER JOIN wiki_data
ON citation_tallies.doi = wiki_data.doi;