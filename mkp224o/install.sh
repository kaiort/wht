git clone https://github.com/cathugger/mkp224o
sudo apt install gcc libc6-dev libsodium-dev make autoconf
cd mkp224o
./autogen.sh
./configure
make
sudo make install
