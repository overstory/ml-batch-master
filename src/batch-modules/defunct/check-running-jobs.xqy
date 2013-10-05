xquery version "1.0-ml";

(:
	This standalone module scans the batch jobs that
	are (supposedly) running.  Any jobs determined to be
	stale are removed, those that appear to be still alive
	are returned.
:)

declare default element namespace "urn://batch-master";

import module namespace bm="urn://batch-master" at
	"../lib/defs.xqy", "../lib/config.xqy", "../lib/functions.xqy";

declare function local:is-stale ($job as element(batch-job)) as xs:boolean
{
	if ($job/launched castable as xs:dateTime)
	then
		if ((fn:current-dateTime() - xs:dateTime ($job/launched)) gt bm:job-stale-interval())
		then (
			bm:bm-log (fn:concat ("BM: deleting stale job: ", bm:job-info ($job)), bm:log-level()),
			fn:true()
		) else fn:false()	(: TODO: check for actual request status?  Need to record in job file at launch :)
	else (
		bm:bm-log (fn:concat ("BM: bad launch time in job: ", xdmp:node-uri ($job), "\n", xdmp:quote($job)), bm:log-level()),
		bm:fail-job (xdmp:node-uri ($job), "stale-lock", ()),
		fn:true()
	)
};

declare function local:remove-job ($job as element (batch-job)) as empty-sequence()
{
	bm:bm-log (fn:concat ("BM: Removing ", xdmp:node-uri ($job)), bm:log-level-debug()),
	xdmp:document-delete (xdmp:node-uri ($job))	(: TODO: Notification strategy :)
};

for $job in fn:collection (bm:running-collection())/batch-job
return
	if (local:is-stale ($job))
	then local:remove-job ($job)
	else $job
