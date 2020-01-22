# Bobcat

The Rails backend for LynxList

## Machine Setup

To run this application on an Ubuntu machine, run the following commands:

```
sudo apt update
sudo apt upgrade
sudo apt install curl vim apt-transport-https
curl -sL https://deb.nodesource.com/setup_13.x | sudo -E bash -
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt update
sudo apt install git build-essential apt-transport-https sqlite3 libssl-dev libreadline-dev zlib1g-dev libsqlite3-dev nodejs zip yarn
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc
source ~/.bashrc
curl -fsSL https://github.com/rbenv/rbenv-installer/raw/master/bin/rbenv-installer | bash
rbenv install 2.6.5
rbenv global 2.6.5
gem install rails sqlite3 --no-document
```

Then clone this repository and enter the main app folder:

```
cd bobcat
bundle
rails db:migrate
rails db:reset
```

Finally, run the server using `rails s`.
