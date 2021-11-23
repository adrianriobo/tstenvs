#!/bin/bash 

terraform output public_ip | sed 's/"//g'