#! /bin/bash

##Use this script for updating and pulling to a git repositorie

git add --all
echo ""
echo "git add -all ,complete"
echo ""
read -p "What comment would you want??" ANS
git commit -m "$ANS"
echo ""
echo "Commit with comment added"
echo ""
git push -u origin main
echo ""
echo "git push -u origin main, completed :)"
