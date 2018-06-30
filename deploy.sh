#!/bin/bash
bundle exec jekyll clean
bundle exec jekyll build -I 

sudo cp -R _site/* /var/www/xxx.com
sudo rm /var/www/xxx.com/deploy.sh
sudo rm /var/www/xxx.com/Gemfile
sudo rm /var/www/xxx.com/Gemfile.lock
sudo rm /var/www/xxx.com/README.md
sudo rm /var/www/xxx.com/index_*/ -rf

exit

