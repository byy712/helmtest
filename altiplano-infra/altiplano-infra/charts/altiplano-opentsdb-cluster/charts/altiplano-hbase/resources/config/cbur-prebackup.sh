#!/bin/bash

echo "Backup HBase Snapshots"
echo "Remove data from /opt/hbase/backup"
rm -rf /opt/hbase/backup/*

/opt/hbase/bin/hbase org.jruby.Main /opt/hbase/hbase-backup.rb
echo "HBase Snapshots Backup Complete"