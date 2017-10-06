##
##    MADE BY dsoler@hofmann.es for Group Security scans
##
##
## INIT
if [ $# -eq 0 ]
  then
    echo
    echo "   Usage"
    echo
    echo "        ./external-bucket-check.sh list-buckets.txt"
    echo
    echo You need to have setted up the credentials for aws cli of another third not related account with S3 permissions
    echo It will create two directories files-lites and files readable with the result.
    echo
    echo
    echo The standard OUTPUT will show
    echo
    echo "        LIST: If the files listing is enabled"
    echo "        WRITE: If I can write a file in the bucket"
    echo "        LISTACL: If I can read the ACL of the buckets"
    echo "        NUMBER OF FILES READABLE: The las number will show the number of files publicaly accesible (with a limit of 1000 checks)."
    echo ; echo;
    exit;
fi;
echo PBX Group security write test>hello.txt
mkdir -p files-listed
mkdir -p files-readable
##
##
case $1 in
'--test-bucket')
# TEST BUCKET
#RESPONSE=`curl -s -o /dev/null -w "%{http_code}"  http://$1.s3.amazonaws.com/`
RESPONSE=`aws s3 ls $2|wc -l`
WRITE=`aws  s3 cp hello.txt  s3://$2/hello.txt |grep upload|grep -v failed|wc -l`
LISTAACL=`aws s3api get-bucket-acl --bucket $2|wc -l`
#echo $1 $RESPONSE
#if test $RESPONSE -ne 403 ; then echo PROBLEM $1 returns $RESPONSE ; fi
echo -n $2 "   "
if test $RESPONSE -ne 0 ; then echo -n LIST, ; aws s3 ls $2 --human-readable --recursive > files-listed/files-$2.txt ; echo -n > logs/files-$2-public.txt ; else echo -n 0,; fi
if test $WRITE -ne 0 ; then
                READWRI=curl -s -o /dev/null -w "%{http_code}"  http://$2.s3.amazonaws.com/hello.txt ;
                if test $READWRI -ne 403 ; then echo -n READ ; fi
                echo -n WRITE, ;
        else
                echo -n 0,;
fi
if test $LISTAACL -ne 0 ; then echo -n LISTACL, ; else echo -n 0,; fi
if test $RESPONSE -ne 0 ; then cat files-listed/files-$2.txt|tail -10000|awk '{print($5)}'|xargs -n1 ./external-bucket-check.sh --check-file $2 ; fi
PUBLIC=`cat logs/files-$2-public.txt|wc -l`
echo  $PUBLIC
##### END TEST BUCKET
;;
'--check-file')
### CHECK FILE
#echo $1 $2 DONE
#if test
wget --spider http://$2.s3.amazonaws.com/$3 >/dev/null 2>/dev/null
OUT=$?
if test $OUT -eq 0; then echo $3 >> files-readable/files-$2-public.txt ; fi
### END check-file
;;
*)
##cat  $1|xargs -n1 ./test-bucket.sh --test-bucket 2>/dev/null
cat  $1|xargs -n1 ./external-bucket-check.sh --test-bucket 2>/dev/null
;;
esac
