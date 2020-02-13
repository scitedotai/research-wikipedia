/* Get the number of valid_doi from wiki_data that do not have citations
(i.e. no corresponding record in citations under target_doi) */

SELECT COUNT(n1.valid_doi)
FROM (SELECT w.id as valid_doi
		FROM wiki_data w
		INNER JOIN doidata d ON d.doi = w.id
		WHERE w.id_type='doi') n1
LEFT JOIN citations c ON c.target_doi = n1.valid_doi
WHERE c.target_doi IS NULL;


/* Query to get wiki_data we don't have cites for, against citation_tallies: */

SELECT COUNT(n1.valid_doi)
FROM (SELECT w.id as valid_doi
		FROM wiki_data w
		INNER JOIN doidata d ON d.doi = w.id
		WHERE w.id_type='doi'
		GROUP BY w.id) n1
LEFT JOIN citation_tallies c ON c.doi = n1.valid_doi
WHERE c.doi IS NULL;


/* Query to get wiki_data we don'�'t have cites for, against citations
(note that this has to do a select distinct, because citation_tallies is
already grouped by doi) */

SELECT COUNT(*)
FROM (SELECT DISTINCT valid_doi FROM (SELECT w.id as valid_doi
	FROM wiki_data w
	INNER JOIN doidata d ON d.doi = w.id
	WHERE w.id_type='doi'
	GROUP BY w.id) n1
LEFT JOIN citations c ON c.target_doi = n1.valid_doi WHERE c.target_doi IS NULL) n2;


/* Query to get wiki_data we do have citations for against citation_tallies: */

SELECT COUNT(n1.valid_doi)
FROM (SELECT w.id as valid_doi
		FROM wiki_data w
		INNER JOIN doidata d ON d.doi = w.id
		WHERE w.id_type='doi'
		GROUP BY w.id) n1
INNER JOIN citation_tallies c ON c.doi = n1.valid_doi;


/* Query to get wiki_data we do have citations for against citations: */

SELECT COUNT(*) FROM (SELECT DISTINCT valid_doi FROM (SELECT w.id as valid_doi
		FROM wiki_data w
		INNER JOIN doidata d ON d.doi = w.id
		WHERE w.id_type='doi'
		GROUP BY w.id) n1
INNER JOIN citations c ON c.target_doi = n1.valid_doi) n2;


/* General tallies for scite citations in our system (for Nature Commentary
report) */

SELECT SUM(total)         AS scite_sum_total,
       SUM(supporting)    AS scite_sum_supporting,
       SUM(contradicting) AS scite_sum_contradicting,
       SUM(mentioning)    AS scite_sum_mentioning,
       SUM(unclassified)  AS scite_sum_unclassified,
       COUNT(*) FILTER(WHERE contradicting > 0 AND supporting = 0) AS scite_count_contradict_without_supporting,
       COUNT(*) FILTER(WHERE supporting > 0 AND contradicting = 0) AS scite_count_support_without_contradict,
       COUNT(*) FILTER(WHERE supporting > 0 AND contradicting > 0) AS scite_count_supporting_and_contradicting,
       COUNT(*) FILTER(WHERE supporting = 0 AND contradicting = 0) AS scite_count_no_supporting_or_contradicting
FROM   citation_tallies;


/* General tallies for wiki cite counts in our system (for Nature Commentary
report) */

SELECT SUM(wiki_total) AS wiki_sum_total,
    SUM(wiki_supporting) AS wiki_sum_supporting,
    SUM(wiki_contradicting) AS wiki_sum_contradicting,
    SUM(wiki_mentioning) AS wiki_sum_mentioning,
    SUM(wiki_unclassified) AS wiki_sum_unclassified,
    COUNT(*) FILTER(WHERE wiki_contradicting > 0 AND wiki_supporting = 0) AS wiki_count_contradict_without_supporting,
    COUNT(*) FILTER(WHERE wiki_supporting > 0 AND wiki_contradicting = 0) AS wiki_count_support_without_contradict,
    COUNT(*) FILTER(WHERE wiki_supporting > 0 AND wiki_contradicting > 0) AS wiki_count_supporting_and_contradicting,
    COUNT(*) FILTER(WHERE wiki_supporting = 0 AND wiki_contradicting = 0) AS wiki_count_no_supporting_or_contradicting
FROM
 (SELECT doi,
     SUM(total) AS wiki_total,
     SUM(supporting) AS wiki_supporting,
     SUM(contradicting) AS wiki_contradicting,
     SUM(mentioning) AS wiki_mentioning,
     SUM(unclassified) AS wiki_unclassified
  FROM wiki_data w
  INNER JOIN citation_tallies c ON c.doi = w.id
  WHERE w.id_type = 'doi'
  GROUP BY doi) t;
