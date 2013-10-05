xquery version "1.0-ml";

import module namespace bm="urn://batch-master" at "batch-modules/lib/defs.xqy";

xdmp:invoke ($bm:bm-master-heartbeat-module, (), $bm:bm-invoke-options)