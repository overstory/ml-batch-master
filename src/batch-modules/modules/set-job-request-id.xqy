xquery version "1.0-ml";

declare default element namespace "urn://batch-master";

declare variable $uri as xs:string external;
declare variable $request-id as xs:unsignedLong external;

declare variable $req-id as element(request-id) := <request-id>{$request-id}</request-id>;
declare variable $job as element(batch-job) := fn:doc($uri)/batch-job;
declare variable $prev-req-id as element(request-id)? := $job/request-id;

if ($prev-req-id)
then xdmp:node-replace ($prev-req-id, $req-id)
else xdmp:node-insert-child ($job, $req-id)
