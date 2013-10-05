xquery version "1.0-ml";

declare default element namespace "urn://batch-master";

declare variable $uri as xs:string external;

declare variable $root as element()? := fn:doc ($uri)/*;
declare variable $touch as element(touched)? := $root/touched;

if ($root)
then if ($touch) then () else xdmp:node-insert-child ($root, <touched>true</touched>)
else ()
