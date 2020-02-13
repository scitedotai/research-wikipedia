select count(*) from citation_tallies inner join wiki_data on citation_tallies.doi = wiki_data.doi;
