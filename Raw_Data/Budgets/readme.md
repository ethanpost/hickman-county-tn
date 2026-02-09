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