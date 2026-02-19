#!/bin/bash
echo "Restore HBase Snapshots"

/opt/hbase/bin/hbase org.jruby.Main /opt/hbase/hbase-restore.rb

echo "HBase Snapshots Restoration Complete"