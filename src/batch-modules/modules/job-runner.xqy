xquery version "1.0-ml";

(:
	This standalone module is the task that runs
	on the Task Server and wraps around the module
	provided by the user.  This module runs the
	module provided by the user, then updates the
	state of the job file to indicate that it's done.
	This module is for internal use only, don't call
	it directly.
:)

declare default element namespace "urn://batch-master";

import module namespace bm="urn://batch-master" at
	"../lib/batch-master-api.xqy", "../lib/functions.xqy",
	"../lib/defs.xqy", "../lib/config.xqy";

declare variable $uri as xs:string external;
declare variable $job as element(batch-job) := fn:doc ($uri)/bm:batch-job;

declare variable $job-invoke-options :=
	<options xmlns="xdmp:eval">
		<database>{if ($job/bm:context-db) then $job/bm:context-db/text() else xdmp:database()}</database>
		<modules>{if ($job/bm:modules-db) then $job/bm:modules-db/text() else xdmp:modules-database()}</modules>
		<root>{if ($job/bm:modules-root) then $job/bm:modules-root/text() else xdmp:modules-root()}</root>
		<isolation>different-transaction</isolation>
		<prevent-deadlocks>true</prevent-deadlocks>
	</options>;

declare function local:record-request-id() as empty-sequence()
{
	xdmp:invoke ($bm:set-job-request-id-module, (fn:QName ("", "uri"), $uri, fn:QName ("", "request-id"), xdmp:request()), $bm:bm-invoke-options)
};

declare function local:invoke-job-module ($job as element(batch-job)) as item()*
{
	xdmp:invoke (fn:string ($job/module), (xs:QName ("param"), $job/param), $job-invoke-options)
};

declare function local:run-job-module() as empty-sequence()
{
	try {
		bm:bm-log (fn:concat ("Running job module: ", $job/module, " (", $job/name, ")"), bm:log-level-debug()),
		local:record-request-id(),
		local:cleanup-job-state (local:invoke-job-module ($job))
	} catch ($e) {
		bm:bm-log (fn:concat ("BM: failure from job '", $job/name, "', ", $e/error:name, "/", $e/error:code), bm:log-level()),
		bm:fail-job ($uri, "run", $e),
		bm:master-heart-beat()
(:
,xdmp:rethrow()
:)
	}
};

declare function local:cleanup-job-state ($result as item()*) as empty-sequence()
{
	(: TODO: handle return value to re-queue, etc :)
	bm:bm-log (fn:concat ("Cleaning up job: ", $job/name), bm:log-level-debug()),
	bm:document-delete-async ($uri)
};

(: ----------------------------------------------------------------- :)

local:run-job-module(),
bm:master-heart-beat()
