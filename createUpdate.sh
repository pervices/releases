#~/bin/bash
if [ -z "$1" ]
  then
    echo "Error - missing arg. Usage: createUpdate.sh <updateDirectory> <updateFileName>"
    exit
fi
if [ -z "$2" ]
  then
    echo "Error - missing arg. Usage: createUpdate.sh <updateDirectory> <updateFileName>"
    exit
fi
updateDirectory=$1;
updateDirNoRel=${updateDirectory//"../"};
updateName=$2;
#Lets first tar it
tar -czvf crimsonUpdate.tar.gz $updateDirectory
#MD5SUM 
updateHash=`md5sum crimsonUpdate.tar.gz|awk '{print $1;}'`


echo 'echo "Extracting files"' > crimsonUpdate.sh
echo "SKIP=\`awk '/^__TARFILE_FOLLOWS__/ { print NR + 1; exit 0; }' \$0\`"  >> crimsonUpdate.sh
echo "THIS=\`pwd\`/\$0"  >> crimsonUpdate.sh
#Take the tarfile and pipe it into tar
echo "tail -n +\$SKIP \$THIS | tar -xz"  >> crimsonUpdate.sh

#create flash script
echo 'echo "Validating update"' >> crimsonUpdate.sh
echo "checkHash=\`tail -n +\$SKIP \$THIS | md5sum |awk '{print \$1;}'\`"  >> crimsonUpdate.sh

echo "if [ \"$updateHash\" != \"\$checkHash\" ] " >> crimsonUpdate.sh
echo 'then ' >> crimsonUpdate.sh
    echo '"MD5SUM Mismatch, try recopying file"' >> crimsonUpdate.sh
    echo "rm -rf $updateDirNoRel" >> crimsonUpdate.sh
    echo "exit" >> crimsonUpdate.sh     
echo 'fi ' >> crimsonUpdate.sh
echo 'echo "OK"' >> crimsonUpdate.sh

#Update crimson
echo "cd $updateDirNoRel" >> crimsonUpdate.sh
echo 'sh update-sd.sh' >> crimsonUpdate.sh
echo "cd ../" >> crimsonUpdate.sh
echo "rm -rf $updateDirNoRel" >> crimsonUpdate.sh
echo 'sleep 3600' >> crimsonUpdate.sh
echo 'echo "Finished"' >> crimsonUpdate.sh
echo 'exit 0' >> crimsonUpdate.sh
echo '__TARFILE_FOLLOWS__' >> crimsonUpdate.sh

#append tar to script
cat crimsonUpdate.sh crimsonUpdate.tar.gz > $updateName 

#remove temperary sh and tarbal
rm crimsonUpdate.sh
rm crimsonUpdate.tar.gz

#lets make it executable
chmod +x $updateName 
