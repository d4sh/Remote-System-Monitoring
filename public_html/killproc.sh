# $1 = name of proc
procid=`pidof $1`

kill $procid

sleep 1

if [ -z "`pidof $1`" ];
then
	echo "$1 murdered!!"
else
	echo "Can't kill the process."
fi
