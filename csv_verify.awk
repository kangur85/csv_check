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

function column_name(i, value)
{
   if (has_headers)
       return "[" i "] " value
   else
       return "Column " i
}

NR == 1 {
    field_cnt=NF
    for (i = 1; i <= NF; ++i) {
        headers[i] = column_name(i,$i)
        if (length(headers[i]) > longest_header_size) {
            longest_header_size = length(headers[i])
        }
    }
    if (has_headers) {
        next
    }
}

BEGIN {
    decimal_regex = decimal
    if (decimal == ".") {
        decimal_regex = "\\."
    }
    new_line_printed=1 # hack for displaying a progress
}

{
    if (NF != field_cnt) {
        if (different_field_cnt++ < max_different_field_cnt || !max_different_field_cnt) {
            if (!new_line_printed) {
                print ""
                new_line_printed=1
            }
            printf("[ERR] Line %d: Number of fields in line (%d) differs from number of fields in the first line (%d)\n", NR, NF, field_cnt) > "/dev/stderr"
        }
    }
    for (i = 1; i <= NF; ++i) {
        if ($i == "") {
            empty_fields[i]++
        }
        else if (match($i, "^[ \t]+$")) {
            whitespaces[i]++
        }
        else if (match($i, "^-?[0-9]*" decimal_regex "[0-9]+$")) {
            floats[i]++
        }
        else if (match($i, "^-?[0-9]+$")) {
            integers[i]++
        }
        else {
            others[i]++
        }
    }
    if (NR % 10000 == 0) {
        printf("\0101[0K\r Lines processed: %d", NR)
        new_line_printed=0
    }
}

END {
        printf("%-" longest_header_size "s\t%10s\t%10s\t%10s\t%10s\t%10s\n",
                  "Name", "Empty", "Integers", "Floats", "Whitespaces", "Others")
        for (i = 1; i <= field_cnt; ++i) {
            printf("%-" longest_header_size "s\t%10d\t%10d\t%10d\t%10d\t%10d\n",
                      headers[i], empty_fields[i], integers[i], floats[i], whitespaces[i], others[i])
        }
        print "Rows processed (incl. headers, if exist): " NR
        if (different_field_cnt > max_different_field_cnt ) {
           printf("First %d out of total %d lines with different number of fields was displayed.\n", max_different_field_cnt, different_field_cnt)
        }

}
