echo "=== Mensagem de commit ==="
read commit_message

echo "=== Deploy full ou quick? (full/quick) ==="
read deploy_type

git add .
git commit -am "$commit_message"
git pull
git push

if [ "$deploy_type" == "full" ]; then
  bundle exec cap production deploy:update_full
else
  bundle exec cap production deploy:update_quick
fi


