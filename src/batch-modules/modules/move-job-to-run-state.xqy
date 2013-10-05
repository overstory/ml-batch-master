xquery version "1.0-ml";

declare default element namespace "urn://batch-master";

import module namespace bm="urn://batch-master" at "../lib/defs.xqy";

declare variable $uri as xs:string external;

declare variable $root as element(batch-job) := fn:doc ($uri)/batch-job;
declare variable $launched as element(launched) := <launched>{fn:current-dateTime()}</launched>;

if (fn:exists ($root/launched))
then xdmp:node-replace ($root/launched, $launched)
else xdmp:node-insert-child ($root, $launched),

xdmp:document-remove-collections ($uri, bm:submitted-collection()),
xdmp:document-add-collections ($uri, bm:running-collection())