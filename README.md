# gradcafe-admissions-data

A repository of admissions data collected from the grad cafe.

CSV files follow this format

Institution, Subject, Degree type and admission semester, Acception/rejection, Method of communication for acceptance/rejection, Date accepted/rejected, GPA, GRE Verbal, GRE Quantitative, GRE Writing, GRE Subject, Student classification (found on Gradcafe website), Date posted, Comments


Note that there are some odd/error cases, for example if a submission has an acceptance/rejection date of 1 Jan 1900, then the user failed to supply their rejection/submission date and 1 Jan 1900 is used in lieu.


If you would like to compile your own data directly from the gradcafe, the file I used and wrote (gradcafebash.sh) is also in this repository. I would suggest running it under Ubuntu Linux. As for how it's used, after navigating the terminal to where the file is located. Run it by first typing (chmod 755 gradcafebash.sh); then by typing (./gradcafebash.sh computer+science) without the parentheses, note that the second word/argument is the subject/institution you are searching for. Also note that all spaces must be substituted with an addition symbol, so instead of typing Massachusetts Institute of Technology, you would type massachusetts+institute+of+technology and hence ./gradcafebash.sh massachusetts+institute+of+technology

The program will produce a few error cases in a sufficiently large dataset, these error cases tend to congregate around the bottom of the spreadsheet and are disproportionately from the year 2006. These error cases are error cases because the formatting of gradcafe was less strict back and the data tends to be incomplete, also my program is built for a more modern dataset.
