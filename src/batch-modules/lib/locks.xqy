xquery version "1.0-ml";

module namespace bm = "urn://batch-master";

import module "urn://batch-master" at "config.xqy", "defs.xqy", "functions.xqy";

declare default element namespace "urn://batch-master";

declare private variable $lock-was-touched-module := "../modules/lock-was-touched.xqy";
declare private variable $touch-lock-module := "../modules/touch-lock.xqy";

(: ---------------------------------------------------------------------- :)

declare function set-master-heartbeat-lock() as xs:boolean
{
	set-lock ($master-lock-doc-uri, $master-lock-root-element-name, master-lock-stale-period())
};

declare function clear-master-heartbeat-lock() as empty-sequence()
{
	clear-lock ($master-lock-doc-uri)
};

declare function master-heartbeat-lock-was-touched() as xs:boolean
{
	lock-was-touched ($master-lock-doc-uri)
};

(: ---------------------------------------------------------------------- :)
(: Generic locking code :)

declare private function lock-was-touched ($lock-doc-uri as xs:string) as xs:boolean
{
	xdmp:invoke ($lock-was-touched-module, (fn:QName ("", "uri"), $lock-doc-uri), $bm-invoke-options)
};

declare private function set-lock ($lock-doc-uri as xs:string, $master-lock-root-element-name as xs:string, $stale-period as xs:dayTimeDuration)
	as xs:boolean
{
	xdmp:invoke ($bm-acquire-lock-module, (fn:QName ("", "uri"), $lock-doc-uri), $bm-invoke-options)

};

declare private function clear-lock ($lock-doc-uri as xs:string) as empty-sequence()
{
	(: must do this in a separate transaction because the lock is not visible in this one :)
	bm:bm-log (fn:concat ("BM: Removing lock: ", $lock-doc-uri), bm:log-level-debug()),
	document-delete-async ($lock-doc-uri)
};
