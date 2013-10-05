xquery version "1.0-ml";

import module namespace bm="urn://batch-master" at "../lib/defs.xqy", "../lib/config.xqy", "../lib/functions.xqy";

declare default element namespace "urn://batch-master";

declare variable $uri as xs:string external;

(: ---------------------------------------------------------------------- :)
(: Generic locking code :)

declare private function local:lock-still-current ($lock-doc-uri as xs:string, $stale-period as xs:dayTimeDuration) as xs:boolean
{
	let $lock-time-element := fn:doc ($lock-doc-uri)/*/start-time
	let $lock-time as xs:dateTime? := if ($lock-time-element castable as xs:dateTime) then xs:dateTime ($lock-time-element) else ()
	let $stale-period := bm:master-lock-stale-period()
	
	return
	if (fn:exists ($lock-time))
	then
		if ((fn:current-dateTime() - $lock-time) gt $stale-period)
		then (
			bm:bm-log (fn:concat ("BM: Lock is stale: ", $lock-doc-uri), bm:log-level-debug()),
			fn:false()	(: lock exists but is older than the stale period :)
		) else (
		    	bm:bm-log (fn:concat ("BM: Lock still current: ", $lock-doc-uri), bm:log-level-debug()),
			fn:true()	(: timestamp exists and is younger than the stale period :)
		)
	else fn:false()			(: no lock document present :)
};

declare private function local:touch-lock ($lock-doc-uri as xs:string) as empty-sequence()
{
	bm:bm-log (fn:concat ("BM: touching active lock: ", $lock-doc-uri), bm:log-level-debug()),

	if (fn:doc ($uri)/*/touched)
	then ()
	else xdmp:node-insert-child (fn:doc ($uri)/*, <touched>true</touched>)
};

declare private function local:create-lock ($uri as xs:string) as empty-sequence()
{
	bm:bm-log (fn:concat ("BM: Creating lock: ", $uri), bm:log-level-debug()),
	xdmp:document-insert ($uri,
		element { $bm:master-lock-root-element-name }
			{ <version>1</version>,<start-time>{fn:current-dateTime()}</start-time> })
};

(: ----------------------------------------------------------------- :)

if (local:lock-still-current ($uri, bm:master-lock-stale-period()))
then (
	local:touch-lock ($uri),
	fn:false()
) else (
	local:create-lock ($uri),
	fn:true()
)
