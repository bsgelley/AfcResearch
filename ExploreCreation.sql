'command that created the original subsetregrel'
CREATE TABLE subsetregrel select * FROM subset_creation INNER JOIN subset_stats USING(user_id) WHERE DATE_ADD(subset_stats.user_registration, INTERVAL 30 DAY) >= subset_creation.rev_timestamp;

'subsetregrel2 with page table included'
CREATE TABLE subsetregrel (UNIQUE(rev_id)) select * FROM subset_creation INNER JOIN subset_stats USING(user_id) INNER JOIN subset_page USING (page_id) WHERE DATE_ADD(subset_stats.user_registration, INTERVAL 30 DAY) >= subset_creation.rev_timestamp;

'try joining with the archive table, which stores deleted revisions'
SELECT * FROM subsetregrel INNER JOIN enwiki_p.archive ON subsetregrel.rev_id = archive.ar_rev_id;
'we want to look at article creation and deletion, so we are interested in namespace 0 here only; we also are looking at new users, so we want only
users who created a page within a month of their registration'


CREATE TABLE fastcreations SELECT `rev_id`, `page_id`, `rev_comment`, `rev_timestamp`, `rev_deleted`, `page_namespace`, `page_title`, `original_namespace`
, `original_title`, `user_id`, `user_name`, `user_registration`, `account_creation_action`, DATEDIFF(nov13_creation.rev_timestamp, nov13_user_stats.user_registration) AS timeregtocreate FROM nov13_user_stats INNER JOIN nov13_creation
USING (`user_id`) INNER JOIN nov13_page_origin USING (`page_id`) WHERE nov13_revision.rev_timestamp > 20060101000000 AND DATEADD(nov13_user_stats.user_registration, INTERVAL 30 DAY) <= nov13_creation.rev_timestamp; 


'updated version of full query'
CREATE TABLE fastcreations SELECT nov13_creation.rev_id AS rev_id, nov13_creation.page_id AS page_id, nov13_creation.rev_comment AS rev_comment, nov13_creation.user_id AS user_id, 
nov13_creation.user_text AS username, nov13_creation.rev_timestamp AS rev_timestamp, nov13_creation.rev_len AS rev_len, nov13_user_stats.user_registration AS registration_timestamp, 
nov13_user_stats.account_creation_action AS creation_action, nov13_page_origin.page_namespace AS namespace, nov13_page_origin.page_title AS page_title,
nov13_page_origin.original_namespace AS orig_namespace, nov13_page_origin.original_title AS orig_title, enwiki_p.logging.log__type AS log_type, enwiki_p.logging.log_action AS log_action, enwiki_p.logging.log_timestamp AS log_timestamp, 
enwiki_p.logging.log_comment AS log_comment FROM nov13_creation AS creation INNER JOIN nov13_user_stats AS users USING (user_id)
INNER JOIN nov13_page_origin AS page USING (page_id) LEFT OUTER JOIN enwiki_p.archive AS archive ON creation.rev_id = archive.ar_rev_id INNER JOIN 
enwiki_p.logging AS logging ON creation.page_id = logging.log_page WHERE creation.rev_timestamp > 20090101000000  AND creation.rev_timestamp <= DATE_ADD(users.user_registration, INTERVAL 30 DAY) AND (page.page_namespace = 0 OR page.original_namespace = 0);