#!/bin/bash

current_date_time=$(date)
s3_buckets=$(aws s3 ls)

echo ${current_date_time}
echo ${s3_buckets}