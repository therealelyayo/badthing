sudo apt-get update
sudo apt-get install git-all
sudo apt-get install make
git clone https://github.com/therealelyayo/evilginx2.git
git clone https://github.com/canha/golang-tools-install-script
cd golang-tools-install-script/
bash goinstall.sh
cd ..
cd ..
cd ..
cd ..
cd ..
cd evilginx2
sudo make build
sudo make install
make
sudo apache2 service stop 
