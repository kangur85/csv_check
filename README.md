# Csv checker

A simple tool for checking data types in delimiter separated files.

## Usage

```bash
/csv_verify.sh
Usage: ./csv_verify.sh [options] csv_file

Where options are:
  -d | --decimal_separator       Decimal separator - for parsing floats
  -c | --max_different_field_cnt Maximum number of ragged line errors.
                                 Regardless the number of lines displayed, a summary
                                 contains the total number of errors. Default: 4
  -f | --field_delimiter         Field delimiter. Default value: "|"
  -s | --suspicious_only         Print suspicious columns and errors only.
  -n | --no_headers              Do not treat the first line as a header.
```
