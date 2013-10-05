xquery version "1.0-ml";

(:
	This module contains the primary API interface
	variables and functions.
:)

module namespace bm="urn://batch-master";

declare default element namespace "urn://batch-master";

import module "urn://batch-master" at "locks.xqy", "config.xqy", "defs.xqy", "functions.xqy";

(: ---------------------------------------------------------------------- :)
(: Private functions only visible in this module :)

declare private function find-jobs() as element(batch-job)*
{
	xdmp:invoke ($bm-find-jobs-module, (), $bm-invoke-options)
};

declare private function launch-job ($job as element(batch-job)) as empty-sequence()
{
	try {
		xdmp:invoke ($bm-launcher-module, (fn:QName ("", "uri"), xdmp:node-uri ($job)), $bm-invoke-options)
	} catch ($e) {
		bm-log (fn:concat ("BM: Cannot launch job: ", job-info ($job), ", exception: ", $e/error:name, "/", $e/error:code), log-level()),
		fail-job (xdmp:node-uri ($job), "launch", $e)
		, xdmp:rethrow()
	}
};

declare private function clear-lock-and-respawn-if-needed() as empty-sequence()
{
	let $was-touched as xs:boolean := master-heartbeat-lock-was-touched()
	let $_ := clear-master-heartbeat-lock()

	return
	if ($was-touched)
	then xdmp:spawn ($bm-master-heartbeat-module, (), $bm:bm-spawn-options)
	else ()
};

declare private function run-heart-beat()
{
	find-jobs()/launch-job(.)
};

(: ---------------------------------------------------------------------- :)
(: Public functions visible to importers of this module :)

declare function master-heart-beat()
{
	if (bm:is-master-enabled())
	then
		try {
			bm-log ("++ BatchMaster heartbeat start", bm:log-level()),
			if (set-master-heartbeat-lock())
			then (
				run-heart-beat(),
				clear-lock-and-respawn-if-needed(),
				bm-log ("-- BatchMaster heartbeat done", bm:log-level())
			)
			else bm-log ("-- BatchMaster heartbeat valid lock present, exiting", bm:log-level())
		} catch ($e) {
			bm-log ("!! BatchMaster heartbeat exception !!", bm:log-level()),
			clear-master-heartbeat-lock(),
			xdmp:rethrow()
		}
	else bm-log ("BatchMaster heartbeat processing is disabled by configuration", bm:log-level())
};
