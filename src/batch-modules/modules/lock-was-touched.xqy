xquery version "1.0-ml";

declare default element namespace "urn://batch-master";

declare variable $uri as xs:string external;

declare variable $touched as element(touched)? := fn:doc ($uri)//touched;

if ($touched castable as xs:boolean)
then xs:boolean ($touched)
else fn:false()
