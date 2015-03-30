# Othello

## What I wrote ?

server.coffee

index.html

client.coffee

Procfile

README.md

## What I did ?

### Preparation

sudo apt-get install git

sudo apt-get install npm

sudo apt-get install nodejs-legacy

sudo npm install -g coffee-script

wget -qO- https://toolbelt.heroku.com/install-ubuntu.sh | sh

### Before

sudo npm init

sudo npm install --save socket.io

git init

heroku login

heroku create ollehto

### After

coffee -c server.coffee

coffee -c client.coffee

git add .

git commit -m "$(date)"

git push heroku master
