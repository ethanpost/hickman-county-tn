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

## Remove comma only lines and lines ending with a comma
^,+$
,$

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

## Add col count field to all rows.

awk '{
  line = $0
  n = 1
  inq = 0
  for (i = 1; i <= length(line); i++) {
    c = substr(line, i, 1)

    if (c == "\"") {
      # If we are inside quotes and see doubled quotes ("")
      if (inq && substr(line, i+1, 1) == "\"") {
        i++              # skip the escaped quote
      } else {
        inq = !inq       # toggle in/out of quoted field
      }
    } else if (c == "," && !inq) {
      n++                # comma outside quotes = field separator
    }
  }
  printf "\"cols=%d\",%s\n", n, line
}' $1 > $1.new

## Combine all files into all_years.csv file

find . -type f -name "all_tables.csv.new" | while read file; do
    cat $file >> all_years.csv
done