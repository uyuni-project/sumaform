#!/bin/bash

# Get script name
SCRIPT=$(basename ${0})

function show_help() {
  echo "Wrapper to help with mirror syncing"
  echo ""
  echo "Syntax: "
  echo ""
  echo "${SCRIPT} <ARGUMENTS>"
  echo ""
  echo "Mandatory arguments:"
  echo ""
  echo " --mirror-images      Mirror QCOW2 images"
  echo " --refresh-scc-data   Refresh data from SCC"
  echo " --apt-mirror         Mirror Apt repositories"
  echo " --minima-sync=<FILE> Use minima to sync repositories specified on <FILE>"
  echo "                      By default: ${HOME}/.minima/minima.yaml"
  echo " --config=<FILE>      Config file with SCC credentials and list of images."
  echo "                      By default: ${HOME}/.minima/mirror.sh.conf"
  echo ""
  echo "If called withou targuments, thiat will be equivalent to calling:"
  echo "${SCRIPT} --mirror-images --refresh-scc-data --apt-mirror --minima-sync=${HOME}/.minima/minima.yaml"
}

function print_incorrect_syntax() {
  echo "ERROR: Incorrect syntax (use -h for help)"
}

function set_error() {
  if [ ${1} -ne 0 ]; then
    ERRORS="TRUE"
  fi
}

function minima_sync() {
  if [ ! -f ${1} ]; then
    echo "ERROR: minima configuration file ${1} does not exist!"
    set_error 1
    return 1
  fi
  minima -c ${1} sync
  set_error ${?}
}

function refresh_scc_data() {
  if [ -z "${SCC_CREDS}" ]; then
    echo "ERROR: configuration file ${CONFIG} does not define SCC_CREDS!"
    set_error 1
    return 1
  fi
  /root/refresh_scc_data.py "$SCC_CREDS"
  set_error ${?}
}

function apt_mirror() {
  /usr/sbin/apt-mirror
  set_error ${?}
}

function mirror_images() {
  if [ -z "${IMAGES}" ]; then
    echo "ERROR: configuration file ${CONFIG} does not define IMAGES!"
    set_error 1
    return 1
  fi
  # will mirror them in /srv/mirror under the same path as the URL
  for IMAGE in ${IMAGES}; do
    wget --mirror --no-host-directories ${IMAGE}
    set_error ${?}
  done
}

function adjust_external_repos() {
  # External repos as nvidia drivers need this to emulate RMT
  # which is what Uyuni/SUSE Manager server expects
  ERROR=0
  if [ -d suse ]; then
    mkdir -p RPMMD
    set_error ${?}
    for dir in suse/sle* ; do
      d=${dir^^}
      ver=${d/SUSE\/SLE/SLE-}
      if [[ $ver == ${ver%SP*} ]]; then
        target="${ver}-GA"
      else
        target=${ver/SP/-SP}
      fi
      full_path=RPMMD/${target}-Desktop-NVIDIA-Driver
      if [ ! -L ${full_path} ]; then
        ln -s ../$dir ${full_path}
	if [ ${?} -ne 0 ]; then
	  ERROR=${?}
	fi
      fi
    done
  fi
  set_error ${?}
}

function final_preparations() {
  jdupes --linkhard -r -s /srv/mirror/
  set_error ${?}
  chmod -R 777 .
  set_error ${?}
}

# No errors detected when we start
ERRORS="FALSE"

# Default place for minima config
MINIMA_CFG="${HOME}/.minima/minima.yaml"

# Default place for mirror.sh.conf
CONFIG="${HOME}/.minima/mirror.sh.conf"

if [ ${#} -eq 0 ]; then
  MIRROR_IMAGES="TRUE"
  REFRESH_SCC_DATA="TRUE"
  APT_MIRROR="TRUE"
  MINIMA_SYNC="TRUE"
else
  ARGS=$(getopt -o h --long help,mirror-images,refresh-scc-data,apt-mirror,minima-sync:,config: -n "${SCRIPT}" -- "$@")
  if [ $? -ne 0 ]; then
    print_incorrect_syntax
    exit 1
  fi
  eval set -- "${ARGS}"
  # extract options and their arguments into variables
  while true; do
    case "${1}" in
      -h|--help)          show_help; exit 1 ;;
      --mirror-images)    MIRROR_IMAGES="TRUE"; shift 1;;
      --refresh-scc-data) REFRESH_SCC_DATA="TRUE"; shift 1;;
      --apt-mirror)       APT_MIRROR="TRUE"; shift 1;;
      --minima-sync)      MINIMA_SYNC="TRUE"; MINIMA_CFG="${2}"; shift 2;;
      --config)           CONFIG="${2}"; shift 2;;
      --)                 shift ; break ;;
      *)                  print_incorrect_syntax; exit 1 ;;
    esac
  done
fi

# This is NOT safe. This is the moment where we should start
# considering python as having complex config files is a nightmare
# in bash (for example a variable with a value with several lines
if [ ! -z "${MIRROR_IMAGES}" -o ! -z "${REFRESH_SCC_DATA}" ]; then
  if [ ! -f ${CONFIG} ]; then
    echo "ERROR: configuration file ${CONFIG} does not exist!"
    exit 1
  fi
  source ${CONFIG}
fi

if [ ! -d /srv/mirror ];then
    mkdir -p /srv/mirror
fi

cd /srv/mirror
if [ ! -z "${MIRROR_IMAGES}" ]; then mirror_images; fi
if [ ! -z "${REFRESH_SCC_DATA}" ]; then refresh_scc_data; fi
if [ ! -z "${APT_MIRROR}" ]; then apt_mirror; fi
if [ ! -z "${MINIMA_SYNC}" ]; then minima_sync "${MINIMA_CFG}"; fi
adjust_external_repos
final_preparations

if [ "${ERRORS}" == "TRUE" ]; then
  exit 1
fi
exit 0
