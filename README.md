## libpinyin Installation (Debian/Ubuntu/Mint)
Note: We installed Ubuntu 20.04 LTS (Focal) with Docker.

apt-get update
apt-get install apt-utils fish autoconf automake libkyotocabinet-dev libpthread-stubs0-dev libtool make pkg-config g++ libglib2.0-dev vim wget -y

fish
cd /root
wget https://github.com/libpinyin/libpinyin/archive/2.3.0.tar.gz
tar xvf 2.3.0.tar.gz
cd libpinyin-2.3.0
set -gx LDFLAGS -lglib-2.0 -lpthread
autoreconf --install
./autogen.sh -with-dbm=KyotoCabinet
make
cd /tests
./test_pinyin