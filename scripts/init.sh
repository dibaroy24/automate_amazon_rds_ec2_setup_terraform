#!/bin/bash
yum update -y
amazon-linux-extras enable postgresql14
yum install -y postgresql

# Wait until RDS is ready
sleep 60

# Create 'random' database
psql -h "${rds_endpoint}" -U admin -d postgres <<EOF
CREATE DATABASE random;
EOF
