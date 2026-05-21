#!/bin/bash

aws autoscaling update-auto-scaling-group \
--auto-scaling-group-name backend-asg \
--desired-capacity 1