#!/bin/bash
set -e  # Exit immediately on error

# Update and install PostgreSQL 14 client tools
yum update -y

# Enable PostgreSQL 14 extras repo
amazon-linux-extras enable postgresql14

# Clean yum metadata and install PostgreSQL 14 client
yum clean metadata
yum install -y postgresql postgresql-server

# Confirm version to ensure libpq >= 10
psql --version
