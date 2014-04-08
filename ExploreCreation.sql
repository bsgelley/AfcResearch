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