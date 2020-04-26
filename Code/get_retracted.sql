-- get list of wikipedia articles that have been retracted
select wiki_data.page_title, wiki_data.doi, doidata.retracted from doidata
inner join wiki_data on doidata.doi = wiki_data.doi
where doidata.retracted = true;

-- get count of unique, retracted dois referenced by wikipedia
select distinct wiki_data.doi
from doidata
inner join wiki_data on doidata.doi = wiki_data.doi
where doidata.retracted = true;
