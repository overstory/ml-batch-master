xquery version "1.0-ml";

(:
	This is a generic module that deletes the document
	at the given URI.  This module is invoked by a query
	request to delete the document independently from
	the scope of the query statement.
:)

declare variable $uri as xs:string external;

if (fn:doc-available ($uri))
then xdmp:document-delete ($uri)
else ()
