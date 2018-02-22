#! /bin/bash
set -e

help() {
    echo "Params:
    -d number of days
    -p path to delete files from" 1>&2
    exit 1
}

while getopts ":h:p:d:" o; do
    case "${o}" in
        p)
            path=${OPTARG};;
        d)
            days=${OPTARG};;
        *)
            help;;
    esac
done

if [ -z "${path}" ] || [ -z "${days}" ]; then
    help
fi

echo "Removing files older than ${days} days..."
find ${path} -not -type d -mtime +${days} -delete
echo "Removing empty dirs..."
find ${path} -type d -empty -delete
