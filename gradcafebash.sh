#!/bin/bash
#Created by James Evans @ The University of South Dakota, https://github.com/evansrjames , jim.evans@coyotes.usd.edu

if [[ -z "$2" ]]
then 
declare -i A="1"
else
A=$2
fi

#URL='https://thegradcafe.com/survey/index.php?q=mathematics&t=a&pp=250&o=&p=60'
#PERMFILE='testfile.html' #for testing purposes only

URL='https://thegradcafe.com/survey/index.php?q='$1'&t=a&pp=250&o=&p='$A # Used to search gradcafe
PERMFILE=$(mktemp tmpXXXXXX)
wget -O $PERMFILE $URL

sed -i '/<\/thead>/,$!d' $PERMFILE  # erases all data before the specified string
sed -i '/<\/thead>/d' $PERMFILE    # erases specified string

if [[ -z "$3" ]]
then
B=$(grep Showing $PERMFILE | awk '{print $5'}) # Grabs the number of pages the program will have to sife through
else
B=$3
fi

sed -i '/<\/table>/q' $PERMFILE        #erases all data after specified string
sed -i '/<\/table>/d' $PERMFILE        #erases specified string
sed -i 's/"/""/g' $PERMFILE #preserving all quotes for eventual compliace with RFC-4180 for CSV files
sed -i 's/.*<td class=""instcol tcol1"">/"/' $PERMFILE #adding initial quotes for University field, and removing garbage
sed -i 's/<\/td><td class=""tcol2"">/","/' $PERMFILE #adding start quotes to subject field for eventual compliace with CSV etc....
sed -i 's/<\/td><td class=""tcol3 accepted""><strong>Accepted<\/strong> via/","Accepted","/' $PERMFILE #The following six lines after this one and this line deal with acceptance/rejection cases
sed -i 's/<\/td><td class=""tcol3 rejected""><strong>Rejected<\/strong> via/","Rejected","/' $PERMFILE
sed -i 's/<\/td><td class=""tcol3 other"">Other via/","Other","/' $PERMFILE
sed -i 's/<\/td><td class=""tcol3 wait[ |-]listed"">Wait[ |-][l\L]isted via/","Wait listed","/' $PERMFILE
sed -i 's/<\/td><td class=""tcol3 interview"">Interview via/","Interview","/' $PERMFILE
sed -i 's/<\/td><td class=""tcol3 ""> via/","Unknown","/' $PERMFILE
sed -i 's/\(Other\|Website\|Phone\|E-[M\|m]ail\|Postal Service\|POST\|Unknown\|  \)\([ ]*on[ ]*\)\(<\/td><td class=""tcol4"">\|<a class=""extinfo""\)/\1 on 1 Jan 1900 \3/I' $PERMFILE #deals with specific error cases where the user fails to submit the date of submission, 1 Jan 1900 is inserted in lieu
sed -i 's/\(","\)\([ ]*\)\(on [0-9][0-9]\?[[:space:]][A-Z][a-z][a-z][[:space:]][0-9][0-9][0-9][0-9][ ]*\)\(<\/td><td class=""tcol4"">\|<a class=""extinfo""\)/\1 Unknown \3\4/' $PERMFILE #deals with specific error case where no acceptance/rejection method is recorded
sed -i 's/\(Other\|Website\|Phone\|E-[M\|m]ail\|Postal Service\|POST\|Unknown\)\([[:space:]]*on[[:space:]]*\)\([0-9][0-9]\?[[:space:]][A-Z][a-z][a-z][[:space:]][0-9][0-9][0-9][0-9]\)/\1","\3","/' $PERMFILE #reformats the date and adds commas etc..
sed -i 's/, \(Masters (.[0-9]*)\|PhD (.[0-9]*)\|Other (.[0-9]*)\|MFA (.[0-9]*)\|MBA (.[0-9]*)\|EdD (.[0-9]*)\| (.[0-9]*)\|JD (.[0-9]*)\|Ph.D (.[0-9]*)\)\(","\)/","\1","/I' $PERMFILE #removing junk and enclosing the choice of study field
sed -i 's/<a class=""extinfo"".*GPA<\/strong>: n\/a//g' $PERMFILE #Filter out GPA and remove code and other junk for formatting purposes
sed -i 's/<a class=""extinfo"".*GPA<\/strong>://g' $PERMFILE #Filter out GPA and remove code and other junk for formatting purposes
sed -i 's/\(<br\/>.*(V\/Q\/W)<\/strong>:[[:space:]]\)\([0-9]*\)\/\([0-9]*\)\/\([0-9]*\.[0-9]*\)/","\2","\3","\4","/' $PERMFILE #filter out GRE scores and format.
sed -i 's/<br\/><strong>GRE Subject<\/strong>: n\/a//' $PERMFILE #remove text preceding subject GRE if no score available
sed -i 's/<br\/><strong>GRE Subject<\/strong>: //' $PERMFILE #remove text preceding subject GRE if score available
sed -i 's/<br\/><\/span>&diams;<\/a>//' $PERMFILE #remove junk
sed -i 's/\([0-9][0-9]\?[[:space:]][A-Z][a-z][a-z][[:space:]][0-9][0-9][0-9][0-9]\)"," <\/td><td class=""tcol4"">/\1","","","","","","/' $PERMFILE #reformatting for users who have no supplied GRE/GPA etc
sed -i 's/<\/td><td class=""tcol4"">/","/' $PERMFILE #formatting
sed -i 's/<\/td><td class=""datecol tcol5"">/","/' $PERMFILE #formatting
sed -i 's/<\/td><td class=""tcol6""><ul class=""control""><li class=""controlspam"">//' $PERMFILE #further formatting etc..
sed -i 's/<\/li><li>/","/' $PERMFILE
sed -i 's/<\/li><\/ul><\/td><\/tr>/"/' $PERMFILE



cat $PERMFILE >> $1.csv
A=$(($A+1))

rm -r $PERMFILE
echo $0

if [[ "$A" -le "$B" ]]
then 
"$0" "$1" "$A" "$B"
fi


exit 0

