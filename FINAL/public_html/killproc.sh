# $1 = name of proc
kill $1

sleep 1

if [ -e `/proc/$1` ];
then
	echo "$1 murdered!!"
else
	echo "Can't kill the process."
fi
