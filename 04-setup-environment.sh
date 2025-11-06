# ssh -i ./ec2-devbox-key-pair.pem ec2-user@EC2

# volume mount
sudo parted -s /dev/nvme1n1 mklabel gpt mkpart primary ext4 0% 100%
sudo mkfs.ext4 /dev/nvme1n1p1
sudo mkdir -p /projects && sudo mount /dev/nvme1n1p1 /projects; blkid -s UUID -o value /dev/nvme1n1p1
# UUID=$(blkid -s UUID -o value /dev/nvme1n1p1); echo "UUID=$UUID /projects ext4 defaults 0 2" | sudo tee -a /etc/fstab
# sudo chown -R $(whoami) /projects

# dev dependencies
sudo yum update
sudo yum groupinstall -y "Development Tools"
sudo yum install -y git
sudo yum install -y autoconf texinfo
sudo yum install -y make gcc
sudo yum install -y zlib-devel
sudo yum install -y libgccjit-devel
sudo yum install -y gnutls-devel
sudo yum install -y ncurses-devel
sudo yum install -y sqlite-devel


# node
git clone https://github.com/nvm-sh/nvm.git /projects/nvm
cd /projects/nvm
sh ./install.sh
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This load
nvm install 20

# rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
. "$HOME/.cargo/env"

cargo install emacs-lsp-booster
cargo install ripgrep
cargo install tree-sitter-cli

# tree sitter
git clone https://github.com/tree-sitter/tree-sitter.git /projects/tree-sitter
cd /projects/tree-sitter
git checkout v0.25.9
make all
sudo make install
echo /usr/local/lib | sudo tee /etc/ld.so.conf.d/local.conf
sudo ldconfig
export LD_LIBRARY_PATH=/usr/local/lib:/usr/local/lib64:$LD_LIBRARY_PATH
export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:/usr/local/share/pkgconfig:$PKG_CONFIG_PATH

# emacs
git clone --depth 1 --branch emacs-30.1 https://github.com/emacs-mirror/emacs.git /projects/emacs
cd /projects/emacs
sh ./autogen.sh
CPPFLAGS="-I/usr/local/include" LDFLAGS="-L/usr/local/lib -Wl,-rpath,/usr/local/lib" PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:/usr/local/share/pkgconfig" sh ./configure --with-modules --with-native-compilation --with-x-toolkit=no --with-sqlite3=yes --with-xpm=ifavailable --with-jpeg=ifavailable --with-png=ifavailable --with-gif=ifavailable --with-tiff=ifavailable --without-pop --with-tree-sitter --without-mailutils CFLAGS="-O3 -Wno-implicit-function-declaration -fno-signed-zeros -funroll-loops -fomit-frame-pointer -fvisibility=hidden -mtune=native -march=native"
make -j16
sudo make install

# init.el
mkdir -p /projects/life
rm -rf ~/.emacs.d/
git clone https://github.com/amirrajan/evil-code-editor.git ~/.emacs.d
emacs -nw
