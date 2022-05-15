# ----------------- Logic for gathering the list of files modified -----------------
# command to get list of files which are modified
clear
str=$(git diff --name-only $(git merge-base master HEAD))
echo 'List of modified files: ---------------------------------------------------------------->> '
separator=" "
modifiedFilesList=(${str//${separator}/ })
for mf in "${modifiedFilesList[@]}"
do
    printf "$mf\n"
done
printf "\n------------------------------------------------------------------------------------\n"

# ----------------- Filter out files as per their extension and run checks -----------------
################## JAVA ##################
# Rule1: Methods of the Test class should be declared as private.
PREV_IFS=$IFS

echo 'Scanning through all the Java files: --------------------------------------------------->> '
for mf in "${modifiedFilesList[@]}"
do
    prevLineWasDash=true
    prevLineAnnotationPresent=false
    if [[ "$mf" == *java ]];
    then
        #printf "$mf\n"
        # Read the file content in a variable and print
        #value=`cat $mf`
        #echo "$value"
        IFS=$'\n'
        # grep -nB 1 "public.*[\(]" "$mf"

        # Find matching lines in the file using grep command and a pattern
        methodLists=($(grep -nB 1 "public.*[\(]" "$mf"))

        for mLine in ${methodLists[@]}
        do
            #printf $mLine
            if [[ $mLine == '--'* ]];
            then
                prevLineWasDash=true
                prevLineAnnotationPresent=false
                continue
            fi
            if [[ $prevLineWasDash == true ]]
            then
                #printf 'inside prevLineWasDash == false block\n'
                if [[ $mLine == *'@Test'* || $mLine == *'@Step'* ]];
                then
                    #printf "line starts with @Test\n"
                    prevLineAnnotationPresent=true
                else
                    #printf "line does not starts with @Test\n"
                    prevLineAnnotationPresent=false
                fi
                prevLineWasDash=false
                continue
            fi
            if [[ $prevLineWasDash == false && $prevLineAnnotationPresent == false ]];
            then
                printf "[WARNING] File: $mf >> $mLine ***** please update to private access modifier instead of public *****\n"
            fi
        done
        printf "\n------------------------------------------------------------------------------------\n"
    fi
done
printf "\n------------------------------------------------------------------------------------\n"

# ------------------------------------------------------------------------------------ #
# Rule4: Story number, Defect number, Testcase id should be mentioned

for mf in "${modifiedFilesList[@]}"
do
    if [[ "$mf" == *java ]];
    then
        IFS=$'\n'

        if ! grep -q "@Story(\|@TestCase(\|@Defect(" "$mf"
        then
            echo '[WARNING] @Story/@TestCase/@Defect not found in '$mf
        fi
    fi
done
printf "\n------------------------------------------------------------------------------------\n"












IFS=$PREV_IFS