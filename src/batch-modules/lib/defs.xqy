xquery version "1.0-ml";

(:
	This module contains definitions used in common
	by the various BatchMaster modules.  Client code
	should not import this module, it is for internal
	use only.
:)

module namespace bm="urn://batch-master";
declare default element namespace "urn://batch-master";

declare variable $master-lock-doc-uri := "/batch-master/master-controller-run-lock.xml";
declare variable $master-lock-root-element-name := "batch-controller-lock";
declare variable $master-lock-stale-period as xs:dayTimeDuration := xs:dayTimeDuration ("PT2M");        (: lock is considered stale after this amount of time :)

declare variable $bm-master-heartbeat-module := "../modules/batch-master.xqy";
declare variable $bm-launcher-module := "../modules/job-launcher.xqy";
declare variable $bm-runner-module := "../modules/job-runner.xqy";
declare variable $bm-find-jobs-module := "../modules/find-jobs.xqy";
declare variable $bm-acquire-lock-module := "../modules/acquire-lock.xqy";
declare variable $bm-check-running-module := "../modules/check-running-jobs.xqy";
declare variable $move-to-run-state-module := "../modules/move-job-to-run-state.xqy";
declare variable $fail-job-module := "../modules/move-job-to-failed-state.xqy";
declare variable $set-job-request-id-module := "../modules/set-job-request-id.xqy";

declare private variable $batch-master-config-uri := "/batch-master/master-config.xml";
declare private variable $job-submitted-collection := "urn://batch-master/job/submitted";
declare private variable $job-running-collection := "urn://batch-master/job/running";
declare private variable $job-failed-collection := "urn://batch-master/job/failed";

declare variable $std-eval-options as element() :=
	<options xmlns="xdmp:eval">
		<isolation>different-transaction</isolation>
		<prevent-deadlocks>true</prevent-deadlocks>
	</options>;

declare variable $bm-spawn-options :=
	<options xmlns="xdmp:eval">
		<modules>{xdmp:modules-database()}</modules>
		<root>BatchMaster/batch-modules</root>
	</options>;

declare variable $bm-invoke-options :=
	<options xmlns="xdmp:eval">
		<modules>{xdmp:modules-database()}</modules>
		<root>BatchMaster/batch-modules</root>
		<isolation>different-transaction</isolation>
		<prevent-deadlocks>true</prevent-deadlocks>
	</options>;


declare function submitted-collection() as xs:string
{
	$job-submitted-collection
};

declare function running-collection() as xs:string
{
	$job-running-collection
};

declare function failed-collection() as xs:string
{
	$job-failed-collection
};

declare function non-failed-collections() as xs:string+
{
	$job-submitted-collection, $job-running-collection
};

declare function master-config-uri()
{
	$batch-master-config-uri
};