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
CREATE TABLE fastcreations SELECT creation.rev_id AS rev_id, creation.page_id AS page_id, creation.rev_comment AS rev_comment, creation.user_id AS user_id, 
creation.user_text AS username, creation.rev_timestamp AS rev_timestamp, creation.rev_len AS rev_len, users.user_registration AS registration_timestamp, 
users.account_creation_action AS creation_action, page.page_namespace AS namespace, page.page_title AS page_title,
page.original_namespace AS orig_namespace, page.original_title AS orig_title, logging.log_type AS log_type, logging.log_action AS log_action, logging.log_timestamp AS log_timestamp, 
logging.log_comment AS log_comment FROM nov13_creation AS creation INNER JOIN nov13_user_stats AS users USING (user_id)
INNER JOIN nov13_page_origin AS page USING (page_id) LEFT OUTER JOIN enwiki_p.archive AS archive ON creation.rev_id = archive.ar_rev_id INNER JOIN 
enwiki_p.logging AS logging ON creation.page_id = logging.log_page WHERE creation.rev_timestamp > 20090101000000  AND creation.rev_timestamp <= DATE_ADD(users.user_registration, INTERVAL 30 DAY) AND (page.page_namespace = 0 OR page.original_namespace = 0);

mysql --defaults-file=~/replica.my.cnf -A -h enwiki.labsdb u4817__afcresearch -e CREATE TABLE `nov13_page` (
  `page_id` int(10) unsigned DEFAULT NULL,
  `page_namespace` int(11) NOT NULL DEFAULT '0',
  `page_title` varbinary(255) NOT NULL DEFAULT '',
  `revisions` bigint(21) NOT NULL DEFAULT '0',
  `first_revision` varbinary(14) DEFAULT NULL,
  `last_revision` varbinary(14) DEFAULT NULL,
  `archived` int(1) NOT NULL DEFAULT '0',
  `first_rev_id` int(8) unsigned DEFAULT NULL,
  UNIQUE KEY `page_name_title` (`page_id`,`page_namespace`,`page_title`),
  KEY `first_revision_idx` (`first_revision`),
  KEY `namespace_title` (`page_namespace`,`page_title`)
  
  optimum 732 367-2582 
  9087834620
  
'query to create a reference table with reg_date + 30 days so we don''t have to look it up multiple times'
CREATE TABLE timeadded (UNIQUE(user_id)) SELECT user_id AS user_id, user_registration AS reg_date, DATE_FORMAT(DATE_ADD(user_registration, INTERVAL 30 DAY), "%Y%m%d%H%i%S") AS thirtydays FROM nov13_user_stats
  
'ignoring null rows (I think there''s some documented reason why they''re there, but not checking now - they''re all totally blank'
 'Get what Jodi wants: for all users who have created an article within the first 2 days of registration, what happens to them/those articles?
 Will they be lower quality, etc. So: select all page creation events (revs) after 01/01/2009 in namespaces 0 (Main), 1 (Talk), 4 (Wikipedia), 5 (Wikipedia talk)
 that were done within 30 days of the user registering on WP. Tables needed: creation, obviously, for creation events and their metadata. User_stats, to get the 
 creating user\'s registration date and type. Page_origin, to get the page\'s title, namespace, original namespace, and original title. Page, to get number
of revisions and deletion proxy (last revision stamp), and if it was deleted (archived). So no mw joins needed.'

CREATE TABLE fastcreations (UNIQUE(rev_id)) SELECT creation.rev_id AS rev_id, creation.page_id AS page_id, creation.rev_comment AS rev_comment, creation.user_id AS user_id, 
creation.user_text AS username, creation.rev_timestamp AS rev_timestamp, creation.rev_len AS rev_len,
users.user_registration AS registration_timestamp, users.account_creation_action AS creation_action, 
page_origin.page_namespace AS namespace, page_origin.page_title AS page_title,
page_origin.original_namespace AS orig_namespace, page_origin.original_title AS orig_title, 
page.revisions, page.last_revision, page.archived 
FROM nov13_creation AS creation 
INNER JOIN nov13_user_stats AS users USING(user_id)
INNER JOIN nov13_page_origin AS page_origin USING(page_id)
INNER JOIN nov13_page AS page USING (page_id, page_namespace, page_title) 
INNER JOIN timeadded USING (user_id)
WHERE creation.rev_timestamp > 20090101000000  AND creation.rev_timestamp <= timeadded.thirtydays AND
(page_origin.original_namespace = 0 OR page_origin.page_namespace = 0 OR page_origin.original_namespace = 1  OR page_origin.page_namespace = 1
OR page_origin.original_namespace = 4 OR page_origin.page_namespace = 4 OR page_origin.original_namespace = 5 OR page_origin.page_namespace = 5)

6463304855
'only partial data'
CREATE TABLE pafastcreations (UNIQUE(rev_id)) SELECT creation.rev_id AS rev_id, creation.page_id AS page_id, creation.rev_comment AS rev_comment, creation.user_id AS user_id, 
creation.user_text AS username, creation.rev_timestamp AS rev_timestamp, creation.rev_len AS rev_len,
users.user_registration AS registration_timestamp, users.account_creation_action AS creation_action, 
page_origin.page_namespace AS namespace, page_origin.page_title AS page_title,
page_origin.original_namespace AS orig_namespace, page_origin.original_title AS orig_title, 
page.revisions, page.last_revision, page.archived 
FROM nov13_creation AS creation 
INNER JOIN nov13_user_stats AS users USING(user_id)
INNER JOIN nov13_page_origin AS page_origin USING(page_id)
INNER JOIN nov13_page AS page USING (page_id, page_namespace, page_title) 
INNER JOIN timeadded USING (user_id)
WHERE creation.rev_timestamp BETWEEN 20090101000000 AND 20090110000000 AND creation.rev_timestamp <= timeadded.thirtydays AND
(page_origin.original_namespace = 0 OR page_origin.page_namespace = 0 OR page_origin.original_namespace = 1  OR page_origin.page_namespace = 1
OR page_origin.original_namespace = 4 OR page_origin.page_namespace = 4 OR page_origin.original_namespace = 5 OR page_origin.page_namespace = 5)