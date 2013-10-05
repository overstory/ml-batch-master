xquery version "1.0-ml";

declare default element namespace "urn://batch-master";

import module namespace bm="urn://batch-master" at "../lib/batch-master-api.xqy", "../lib/defs.xqy";

declare variable $uri as xs:string external;
declare variable $where as xs:string external;
declare variable $exception as element(error:error)? external;

declare variable $root as element(batch-job) := fn:doc ($uri)/batch-job;
declare variable $failure as element(failure) :=
	<failure>
		<where>{$where}</where>
		{
			if (fn:exists ($exception))
			then <exception>{$exception}</exception>
			else ()
		}
	</failure>;

if (fn:exists ($root/failure))
then xdmp:node-replace ($root/failure, $failure)
else xdmp:node-insert-child ($root, $failure),

xdmp:document-remove-collections ($uri, bm:non-failed-collections()),
xdmp:document-add-collections ($uri, bm:failed-collection())
