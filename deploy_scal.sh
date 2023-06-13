REMOTE_HOST=wakizaka24@wakizaka24.sakura.ne.jp
PATH_TO_REPLACE=/home/wakizaka24/www/scal/deploy
ssh $REMOTE_HOST mkdir $PATH_TO_REPLACE
ssh $REMOTE_HOST rm -rf $PATH_TO_REPLACE/*
cd ./deploy
for FILE in `ls -A | grep --line-buffered -v .DS_Store`; do
    rsync -a --exclude .DS_Store ${FILE} $REMOTE_HOST:$PATH_TO_REPLACE
done
open https://wakizaka24.sakura.ne.jp/scal/deploy/demo1