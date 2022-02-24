#!/usr/bin/env bash

# restore data backed up with paperbackup.py

# give one file containing all qrcodes as parameter

SCANNEDFILE="$1"

if [ "$(uname)" = "Darwin" ]; then
    PATH="/usr/local/bin:$PATH"
    alias sed="gsed"
fi

if [ -z "$SCANNEDFILE" ]; then
    echo "give one file containing all qrcodes as parameter"
    exit 1
fi

if [ ! -f "$SCANNEDFILE" ]; then
    echo "$SCANNEDFILE is not a file" > /dev/stderr
    exit 1
fi

which zbarimg > /dev/null 2>&1 || {
    echo "zbarimg not found in PATH" > /dev/stderr
    exit 2
}

# zbarimg ends each scanned code with a newline

# each barcode content begins with ^<number><space>
# so convert that to \0<number><space>, so sort can sort on that
# then remove all \n\0<number><space> so we get the originial without newlines added

zbarimg --raw -Sdisable -Sqrcode.enable "$SCANNEDFILE" \
    | sed -e "s/\^/\x0/g" \
    | sort -z -n \
    | sed ':a;N;$!ba;s/\n\x0[0-9]* //g;s/\x0[0-9]* //g;s/\n\x0//g'