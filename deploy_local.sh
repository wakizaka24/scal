if [ $# = 0 ]; then
FOLDER_NAME=`date "+%Y%m%d_%H%M_%S"`
else
FOLDER_NAME=$1
fi

rm -rf ./build/web
fvm flutter build web --web-renderer canvaskit -t lib/main.dart
cd ./build/web
# base href="/" -> base href="/scal/deploy/20230521_1852_37/"
# sed -e "s/base href=\"\/\"/base href=\"\/scal\/deploy\/20230521_1852_37\/\"/g" ./index.html
mv index.html index_backup.html
sed -e "s/base href=\"\/\"/base href=\"\/scal\/deploy\/$FOLDER_NAME\/\"/g" index_backup.html > index.html
rm -rf ../../deploy/$FOLDER_NAME
mkdir ../../deploy/$FOLDER_NAME
for FILE in `ls -A | grep --line-buffered -v .DS_Store`; do
    rsync -a --exclude .DS_Store ${FILE} ../../deploy/$FOLDER_NAME
done
