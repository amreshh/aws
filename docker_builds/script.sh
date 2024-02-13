#!/bin/bash -x

timestamp=$(date +%s)
s3_buckets=$(aws s3 ls)

echo "${s3_buckets}"
echo "${timestamp}: ${s3_buckets}" > /tmp/s3_test.txt

aws s3 cp /tmp/s3_test.txt s3://eu-central-1-905418158245-data/test/