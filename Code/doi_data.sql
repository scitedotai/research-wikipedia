select count(*) from wiki_data;
-- 2002895
select count(*) from wiki_data where doi is not null;
-- 1923575
select count(*) from doidata inner join wiki_data on doidata.doi = wiki_data.doi;
-- 1880649