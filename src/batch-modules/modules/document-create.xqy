xquery version "1.0-ml";

declare variable $uri as xs:string external;
declare variable $content as element() external;

xdmp:document-insert ($uri, $content)
