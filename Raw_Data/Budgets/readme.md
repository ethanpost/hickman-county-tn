## cat Files
cat table-{1..58}.csv > all_tables.csv

## 
Replace ""' with "'
Replace "$ "

## Remove confidence scores.
^[^A-Za-z]*(""|"[0-9.-]+")(,"[0-9.-]+"){3,},?$
^(?:"")?"'[0-9]+(?:\.[0-9]+)?"(?:,"'[0-9]+(?:\.[0-9]+)?")+,\r?$
^[^A-Za-z]*"[0-9]+(?:\.[0-9]+)?"(?:,"[0-9]+(?:\.[0-9]+)?")+,\s*$|^[^A-Za-z]*"[0-9]+(?:\.[0-9]+)?"(?:,"[0-9]+(?:\.[0-9]+)?")+\s*$
.*Confidence Scores.*

## Remove comma only lines.
^,+$

## Remove lines with only double quotes and commas.
^[",]+$

## Remove blank lines.
^\s*\n


## Add line numbers
find /c/home/hickman-county-tn/Raw_Data/Budgets -type f -name "all_tables.csv" | while read file; do
    d=$(dirname $file)
    b=$(basename $file)
    cp $file ${d}/$b.bak
    awk '{print "\"" NR "\"," $0}' ${d}/$b.bak > $file
done