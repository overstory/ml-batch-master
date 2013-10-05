xquery version "1.0-ml";

(:
	This module contains functions used in common
	by the various BatchMaster modules.  Client code
	should not import this module, it is for internal
	use only.
:)

module namespace bm="urn://batch-master";
declare default element namespace "urn://batch-master";

import module "urn://batch-master" at "defs.xqy";

declare variable $delete-doc-module := "../modules/document-delete.xqy";
declare variable $create-doc-module := "../modules/document-create.xqy";

(: --------------------------------------------------------- :)

declare function document-delete-async ($uri as xs:string)
{
	xdmp:invoke ($delete-doc-module, (fn:QName("", "uri"), $uri), $bm-invoke-options)
};

declare function document-create-async ($uri as xs:string, $content as element()) as empty-sequence()
{
	xdmp:invoke ($create-doc-module,
		(fn:QName("", "uri"), $uri, fn:QName ("", "content"), $content),
		$bm-invoke-options)
};

(: --------------------------------------------------------- :)

declare function job-info ($job as element(batch-job)) as xs:string
{
	fn:concat ("Job: ", $job/name, ", priority: ", $job/priority, ", launched: ", $job/launched, ", URI: ", xdmp:node-uri ($job))
};

declare function fail-job ($uri as xs:string, $where as xs:string,
	$exception as element(error:error)?) as empty-sequence()
{
	xdmp:invoke ($bm:fail-job-module,
		(fn:QName("", "uri"), $uri, fn:QName("", "where"), $where, fn:QName("", "exception"), $exception),
		$bm-invoke-options)
};

(: --------------------------------------------------------- :)

declare function bm-log ($msg, $level)
{
	xdmp:log (fn:concat ("[", xdmp:request(), "] ", $msg), $level)
};
