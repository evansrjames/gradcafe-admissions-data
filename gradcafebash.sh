#!/bin/bash
#Created by James Evans @ The University of South Dakota, https://github.com/evansrjames

if [[ -z "$2" ]]
then 
declare -i A="1"
else
A=$2
fi

#URL='https://thegradcafe.com/survey/index.php?q=mathematics&t=a&pp=250&o=&p=39'
#PERMFILE=test.txt #for testing purposes only

URL='https://thegradcafe.com/survey/index.php?q='$1'&t=a&pp=250&o=&p='$A # Used to search gradcafe
PERMFILE=$(mktemp tmpXXXXXX)

wget -O $PERMFILE $URL

sed -i '/<!-- google_ad_section_start -->/,$!d' $PERMFILE    # erases all data before the specified string
sed -i '/<!-- google_ad_section_start -->/d' $PERMFILE    # erases specified string

if [[ -z "$3" ]]
then
B=$(grep Showing $PERMFILE | awk '{print $5'}) # Grabs the number of pages the program will have to sife through
else
B=$3
fi

sed -i '/<\/table>/q' $PERMFILE        #erases all data after specified string
sed -i '/<\/table>/d' $PERMFILE        #erases specified string
sed -i 's/"/""/g' $PERMFILE #preserving all quotes for eventual compliace with RFC-4180 for CSV files
sed -i 's/.*<td class=""instcol"">/"/' $PERMFILE #adding initial quotes for University field, and removing garbage
sed -i 's/<\/td><td>/","/' $PERMFILE #adding start quotes to subject field for eventual compliace with CSV etc....
sed -i 's/, \(Masters (.[0-9]*)\|PhD (.[0-9]*)\|Other (.[0-9]*)\|MFA (.[0-9]*)\|MBA (.[0-9]*)\|EdD (.[0-9]*)\| (.[0-9]*)\|JD (.[0-9]*)\)\(<\/td><td>\)/", \1,/I' $PERMFILE #removing junk and enclosing the choice of study field
sed -i 's/via/,/' $PERMFILE #remove junk, add commas
sed -i 's/<span class=""d.*ted"">//' $PERMFILE #eject junk before accepted/rejected
sed -i 's/\(Accepted\|Rejected\)<\/span>/\1/I' $PERMFILE #remove junk after accepted/rejected
sed -i 's/\(Other\|Website\|Phone\|E-mail\|Postal Service\)\([[:space:]]*on[[:space:]]*\)\(<\/td><td>\|<a class\=\)/\1 on 1 Jan 1900 \3/I' $PERMFILE #deals with specific error cases where the user fails to submit the date of submission, 1 Jan 1900 is inserted in lieu
sed -i 's/\(Accepted\|Rejected\|Wait listed\|Interview\|Other\|\)\( , \)\(Other\|Website\|Phone\|E-mail\|Postal Service\|Unknown\|Postal\|\)\( on \)\([0-9]\|[0-9][0-9] .[0-9][0-9] [0-9][0-9][0-9][0-9]\)/\1\2\3,\5/I' $PERMFILE #adding comma between acceptance/rejection etc and the method of acceptance/rejection etc
sed -i 's/<a class=""extinfo"" href=""#""><span><strong>Undergrad GPA<\/strong>:/,/' $PERMFILE #Adding comma before undegrad GPA
sed -i 's/<br\/><strong>GRE General (V\/Q\/W)<\/strong>: \([0-9]\+\)\/\([0-9]\+\)\/\([0-9]\.*[0-9]*\)/,\1,\2,\3,/' $PERMFILE #adding commas between GRE scores
sed -i 's/<br\/><strong>GRE Subject<\/strong>://' $PERMFILE #removing junk after gre subject score
sed -i 's/<br\/><\/span>&diams;<\/a>//' $PERMFILE #removing junk 
sed -i 's/\(n\/a\|[^0-9][0-9]\|[^0-9][0-9][0-9]\|[^0-9][0-9][0-9][0-9]\)<\/td><td>\(I\|A\|O\|U\|?\)<\/td><td class=""datecol"">/\1,\2,/' $PERMFILE #case 1, GRE and correct student classification
sed -i 's/\(n\/a\|[^0-9][0-9]\|[^0-9][0-9][0-9]\|[^0-9][0-9][0-9][0-9]\)<\/td><td><\/td><td class=""datecol"">/\1,?,/' $PERMFILE #case 2, GRE and no student classification, unverified if it works
sed -i 's/\([0-9][0-9][0-9][0-9]\) <\/td><td>\(I\|A\|O\|U\|?\)<\/td><td class=""datecol"">/\1,,,,,,\2,/' $PERMFILE #case 3, no GRE and student classification.
sed -i 's/\([0-9][0-9][0-9][0-9]\) <\/td><td><\/td><td class=""datecol"">/\1,,,,,,?,/' $PERMFILE #case 4, no GRE and no student classification
sed -i 's/<\/td><td><ul class=""control""><li class=""controlspam""><\/li><li>/,"/' $PERMFILE #adding comma before comments, quotes to adhere to CSV specification
sed -i 's/<\/li><\/ul><\/td><\/tr>/"/' $PERMFILE #adding quotes after comments


cat $PERMFILE >> $1.csv
A=$(($A+1))

rm -r $PERMFILE
echo $0

if [[ "$A" -lt "$B" ]]
then 
"$0" "$1" "$A" "$B"
fi


exit 0

