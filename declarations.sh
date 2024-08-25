#!/usr/bin/env bash
# Declarations for Bakki only

# Define a placeholder space character for use in a configuration file
declare placeholder_space="#x0020"

# Define standardnames
declare config_stdname="config.xml"

# Define associative arrays with desired elements & first allocation
declare -A script_=(
    [dir]=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"/"    # hier auch v
    [name]=$(basename "${BASH_SOURCE[0]}")                                            #??? configreader.sh?
    [config]="$config_stdname"
)
declare -A config_elements=(
    [version]=''
    [version_strg]=''
    [lang]=''
    [title_strg]=''
    [menue_strg]=''
    [config_strg]=''
    [editor_prog]=''
    [prog_strg]='meld'   #????
    [home_directory]=''
    [storage_location]=''
    [standard_path]=''
    [remote_path]=''
)

# Define parameter of sync-group-elements
declare -a id;

declare -i num_elements=3
declare -a opti1; opti1[0]="name"
declare -a opti2; opti2[0]="dir1"
declare -a opti3; opti3[0]="dir2"
declare -a opti4; opti4[0]=""
declare -a opti5; opti5[0]=""
declare -a opti6; opti6[0]=""
declare -a opti7; opti7[0]=""

# Workparameters
declare -i cmdNr=0 && unset cmdNr
declare selection=""
declare selectedIndex=""

 script_[name]=$(basename "${BASH_SOURCE[0]}")
#return 



#### junk

declare -A optionKW=(
	[name]=''
	[param]=''
	[dir1]=''
	[dir2]=''
)


#declare -a sync_name     #oppti1
#declare -a sync_param    
#declare -a sync_dir1    #optti2
#declare -a sync_dir2    #oppti3

declare -a template_name
declare -a template_prog
declare -a template_param
declare -a template_path
declare -a template_file
