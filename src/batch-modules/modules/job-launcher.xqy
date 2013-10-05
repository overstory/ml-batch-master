xquery version "1.0-ml";

(:
	This standalone module is responsible for
	launching a new job.  That entails moving the
	job control document from the submitted to the
	running collection, then spawning a new task
	to run the job asynchronously.
:)

declare default element namespace "urn://batch-master";

import module namespace bm="urn://batch-master" at "../lib/defs.xqy", "../lib/config.xqy", "../lib/functions.xqy";

declare variable $uri as xs:string external;
declare variable $job as element(batch-job) := fn:doc ($uri)/batch-job;

declare function local:validate-job ($job as element(batch-job)) as empty-sequence()
{
	(: TODO :)
};

declare function local:move-to-run-state ($job as element(batch-job)) as empty-sequence()
{
	xdmp:invoke ($bm:move-to-run-state-module, (fn:QName ("", "uri"), $uri), $bm:bm-invoke-options)
};

declare function local:spawn-job ($job as element(batch-job)) as empty-sequence()
{
(:
	bm-log (fn:concat ("Launching job: ", $job/name, ", pri=", $job/priority, ", create: ", $job/created), bm:log-level())
:)
	xdmp:spawn ($bm:bm-runner-module, (fn:QName ("", "uri"), $uri), $bm:bm-spawn-options)
};

(: --------------------------------------------------------------- :)

bm:bm-log (fn:concat ("Attempting to launch job: ", $uri), bm:log-level-debug()),
local:validate-job ($job),
local:move-to-run-state ($job),
bm:bm-log (fn:concat ("Changed to run state, spawning: ", $uri), bm:log-level-debug()),
local:spawn-job ($job)


