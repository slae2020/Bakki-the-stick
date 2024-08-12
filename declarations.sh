#!/usr/bin/env bash

# Define parameter of sync-group-elements
declare -a id=

declare -A option=(
	[name]=''
	[param]=''
	[dir1]=''
	[dir2]=''
)
declare -a sync_name
declare -a sync_param
declare -a sync_dir1
declare -a sync_dir2

declare -a template_name
declare -a template_prog
declare -a template_param
declare -a template_path
declare -a template_file

declare -i num_elements=4

# Workparameters
declare -i cmdNr=0 && unset cmdNr
declare selection=""
