#!/usr/bin/env bash
#
# CSV checker
# Copyright © 2016 Krzysztof Kaszkowiak
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
# DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
# OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# To get a help, execute the script without any parameters.

# Parse parameters
OPTS=`getopt -o d:c:f:sn -n 'csv_verify' -- "$@"`

# Default options
DECIMAL=.
SUSPICIOUS_ONLY=0
HEADERS=1
MAX_DIFFERENT_FIELD_CNT=4
FIELD_DELIMITER=|

if [ $? != 0 ] ; then
    echo "Failed parsing options." >&2 ;
    exit 1 ;
fi
eval set -- "$OPTS"


while true ; do
    case "$1" in
      -d|--decimal_separator) DECIMAL=$2 ; shift 2 ;;
      -c|--max_different_field_cnt) MAX_DIFFERENT_FIELD_CNT=$2 ; shift 2 ;;
      -f|--field_delimiter)
          case "$2" in
              "" ) shift 2;;
               * ) FIELD_DELIMITER=$2; shift 2;;
          esac;;
      -s|--suspicious_only) SUSPICIOUS_ONLY=1 ; shift ;;
      -n|--no_headers) HEADERS=0 ; shift ;;
      --) shift ; break ;;
      *) echo "Internal error!" ; exit 1 ;;
    esac
done
shift $(( OPTIND - 1 ));

# Check dependencies
AWK=$( which awk )
if [ -z "$AWK" ]; then
    print_and_die "awk couldn't be found."
fi

CSV_FILENAME="$1"
AWK_SCRIPT_FILENAME="csv_verify.awk"

echo "debug:: suspicious_only=$SUSPICIOUS_ONLY max_different_fields_cnt=$MAX_DIFFERENT_FIELD_CNT"
echo "debug:: decimal=$DECIMAL has_headers=$HEADERS field_delimiter=$FIELD_DELIMITER"
echo "debug:: awk script=$AWK_SCRIPT_FILENAME, csv_filename=$CSV_FILENAME"

$AWK -v "suspicious_only=$SUSPICIOUS_ONLY" -v "max_different_field_cnt=$MAX_DIFFERENT_FIELD_CNT" -v "decimal=$DECIMAL" -v "has_headers=$HEADERS" -F"$FIELD_DELIMITER" -f $AWK_SCRIPT_FILENAME $CSV_FILENAME

function print_and_die {
    echo "$1"
    exit 1
}
