#!/bin/bash

#saving users input:
folderPath=$1
programName=$2
shift 2
argsForProgram=$@

#creating this var to store the value to be returned by the program
valToReturn=0
#creating a var for returned values - as there will be some
returnedVal=0

#directory change to the chosen one by user
cd $folderPath > /dev/null 2>&1
returnedVal=$?
if [ "$returnedVal" -ne 0 ]; then
echo "wrong path asked - exiting with error code -666"
exit -666
fi
 
#starting the makeFile 
make > /dev/null 2>&1
returnedVal=$?

#checking "make" return value - did the function succeed
if [ "$returnedVal" -ne 0 ]; then
echo "Compilation	Memory leaks	thread race"
echo "  failed      ->      [CANT CHECK NOTHING]"
exit 7
fi 

#checking the exe with valgrind - for memory leaks
valgrind -q --leak-check=full --error-exitcode=9 ./$programName $argsForProgram > /dev/null 2>&1
returnedVal=$?

#checking "valgrind" return value - did the function succeed
if [ "$returnedVal" -eq 9 ]; then
valToReturn=2
fi 

 
#checking the exe with helgrind - for race condition
valgrind -q --tool=helgrind --error-exitcode=8 ./$programName $argsForProgram > /dev/null 2>&1
returnedVal=$?


#checking "helgrind" return value - did the function succeed
if [ "$returnedVal" -eq 8 ]; then
((valToReturn++))
fi 

#printing the output as specified 
echo "Compilation	Memory leaks	thread race"
if [ "$valToReturn" -eq 2 ]; then
echo "PASSED	         FAILED	           PASSED"
elif [ "$valToReturn" -eq 3 ]; then
echo "PASSED	         FAILED	         FAILED"
elif [ "$valToReturn" -eq 1 ]; then
echo "PASSED	         PASSED	         FAILED"
else
echo "PASSED	         PASSED	         PASSED"
fi

exit "$valToReturn"
