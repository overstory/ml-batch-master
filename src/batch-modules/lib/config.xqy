xquery version "1.0-ml";

(:
	This module contains definitions and functions
	related to configuration.
	BatchMaster global configuration is controlled by a single
	XML document with the URI defined in the variable $batch-master-config-uri
:)

module namespace bm="urn://batch-master";

declare default element namespace "urn://batch-master";

import module "urn://batch-master" at "defs.xqy";

(: ---------------------------------------------------------------------- :)
(: Private variables only visible in this module :)

declare private variable $default-master-config as element(batch-master-config) :=
	<batch-master-config>
		<version>1</version>
		<enabled>true</enabled>
		<max-concurrent-jobs>4</max-concurrent-jobs>
		<job-stale-interval>PT30M</job-stale-interval>
		<controller-stale-interval>PT2M</controller-stale-interval>
		<log-level>info</log-level>
		<debug-log-level>debug</debug-log-level>
		<master-lock-uri>{$master-lock-doc-uri}</master-lock-uri>
	</batch-master-config>;

declare private variable $master-config as element(batch-master-config) :=
	if (fn:doc-available (master-config-uri()))
	then
		if (fn:doc (master-config-uri())/batch-master-config)
		then fn:doc (master-config-uri())/batch-master-config
		else fn:error(xs:QName("err:BADCONFIG"), "Document is not a BatchMaster config", master-config-uri())
	else $default-master-config;

declare private variable $default-log-level := "info";
declare private variable $default-debug-log-level := "debug";

(: ---------------------------------------------------------------------- :)
(: Public functions visible to importers of this module :)

declare function is-master-enabled() as xs:boolean
{
	xs:boolean ($master-config/enabled)
};

declare function master-lock-doc-uri()
{
	if ($master-config/master-lock-uri)
	then fn:string ($master-config/master-lock-uri)
	else $master-lock-doc-uri
};

declare function master-lock-stale-period() as xs:dayTimeDuration
{
	xs:dayTimeDuration ($master-config/controller-stale-interval)
};

declare function log-level() as xs:string
{
	if ($master-config/log-level)
	then fn:string ($master-config/log-level)
	else $default-log-level
};

declare function log-level-debug() as xs:string
{
	if ($master-config/debug-log-level)
	then fn:string ($master-config/debug-log-level)
	else $default-log-level
};

declare function max-concurrent-jobs() as xs:integer
{
	xs:integer ($master-config/max-concurrent-jobs)
};

declare function job-stale-interval() as xs:dayTimeDuration
{
	xs:dayTimeDuration ($master-config/job-stale-interval)
};