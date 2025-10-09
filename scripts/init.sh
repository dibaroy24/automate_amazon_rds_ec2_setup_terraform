#!/bin/bash
yum update -y
amazon-linux-extras enable postgresql14
yum install -y postgresql

# Wait until RDS is ready
sleep 60

# Create 'random' database
RDS_PSQL_ENDPOINT = "$(terraform output -raw rds_endpoint)"
# psql -h "${rds_endpoint}" -U admin -d postgres <<EOF
psql -h $RDS_PSQL_ENDPOINT -U "${var.admin_user}" -d "${var.new_db}" <<EOF
CREATE DATABASE random;
EOF
