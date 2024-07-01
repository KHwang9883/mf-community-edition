@echo off
git add .
git reset --hard
cd engine
git add .
git reset --hard
cd ..
git pull
git submodule update --remote
