All files contain a sample of 100 users. Files are tab-separated and may look funny until 
imported into Excel or the like 

The below files contain just the user names and ids and counts of created (total) kept, and deleted pages.

onecreatedanddeleted.tsv, onecreatedandkept.tsv = users who created one page and it was deleted, or it was kept, 
respectively. These users have a deletion rate of 0 or 1, but from only 1 page.

manycreatedandallkept.tsv, manycreatedandalldeleted.tsv = users who created many pages and they were either all
deleted or all kept - deletion rate of 0 or 1, respectively

mixedprops.tsv = users who created several pages, with a deletion rate >0 and < 1

The files with 'pages' in their names below contain the actual page titles and namespaces, along with the user
name and user id
onedeletedpages.tsv, onekeptpages.tsv - the pages created by the samples of 100 users each who each created 
1 page; onedeletedpages contains pages created by the users in onecreatedanddeleted, and the opposite for onekeptpages

manykeptpages.tsv, manydeletedpages.tsv - the pages created by the samples of 100 who each created > 1 page, and
all of that user's pages were either kept or all deleted. So these have > 100 pages in each one. 

mixedpages.tsv - pages from users who had some pages kept, some deleted. This has an additional field, 
`deleted`, denoting whether or not the page was deleted. 0 in the deleted field means not deleted, 
and 1 means deleted.
