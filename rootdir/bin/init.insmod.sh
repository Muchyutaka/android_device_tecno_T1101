#!/vendor/bin/sh

########################################################
### init.insmod.cfg format:                          ###
### -----------------------------------------------  ###
### [insmod|setprop|enable/moprobe] [path|prop name] ###
### ...                                              ###
########################################################

if [ $# -eq 1 ]; then
  cfg_file=$1
else
  exit 1
fi

# Android 12+ may place vendor modules in vendor_dlkm instead of vendor.
module_dir=/vendor/lib/modules
if [ -d /vendor_dlkm/lib/modules ]; then
  module_dir=/vendor_dlkm/lib/modules
fi

if [ -f $cfg_file ]; then
  while IFS="|" read -r action arg
  do
    case $action in
      "insmod") insmod $arg ;;
      "setprop") setprop $arg 1 ;;
      "enable") echo 1 > $arg ;;
      "modprobe")
        case ${arg} in
          "-b *" | "-b")
            arg="-b $(cat ${module_dir}/modules.load)" ;;
          "*" | "")
            arg="$(cat ${module_dir}/modules.load)" ;;
        esac
        modprobe -a -d ${module_dir} $arg ;;
    esac
  done < $cfg_file
fi

