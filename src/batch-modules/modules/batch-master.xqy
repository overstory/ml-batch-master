xquery version "1.0-ml";

import module namespace bm="urn://batch-master" at "../lib/batch-master-api.xqy";

declare default element namespace "urn://batch-master";

declare variable $wait-for-lock as xs:boolean external;

declare function local:debug-verify-is-query() as empty-sequence()
{
	if (fn:empty (xdmp:request-timestamp()))
	then fn:error ((), "**** THIS MUST BE A QUERY, NOT AN UPDATE ****")
	else ()
};

local:debug-verify-is-query(),
bm:master-heart-beat()

