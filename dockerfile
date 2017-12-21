# ======================================================================
# usage: docker run -ti -p 8888:8888 karenyng/miniconda3_devenv:latest 
# within the container, use jupyter notebook with:
# $ jupyter notebook --ip 0.0.0.0 --no-browser --allow-root -v ${PWD}:/code/DataScience
# then navigate to your local browser and go to the url:
# 127.0.0.1:8888
# ======================================================================
FROM continuumio/miniconda3:latest
MAINTAINER Karen Ng <karen.yyng@gmail.com>

ENV DEBIAN_FRONTEND noninteractive
RUN chsh -s /bin/bash root
RUN echo 'geronimo\ngeronimo' | passwd root
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
RUN touch /root/.bashrc
ENV PATH /opt/conda/bin:$PATH
RUN echo "PATH=$PATH" >> /root/.bashrc
RUN echo 'deb http://ftp.us.debian.org/debian experimental main' >> /etc/apt/sources.list
RUN echo 'deb http://ftp.us.debian.org/debian sid main' >> /etc/apt/sources.list

# install libraries needed for installation of other libraries
RUN apt update -y && apt install -y build-essential \ 
cmake \
git \ 
locate \
neovim \
neovim-runtime \
unzip \
wget 
### make sure we have all the python utilities to make ipython and conda useful 
RUN apt install -y ncurses-dev xorg-dev 
RUN pip install --upgrade gnureadline binstar
RUN apt-get autoremove -y

### ---------  set up personal work env ------------------  
RUN apt install -y \
exuberant-ctags \
python3-neovim \
# for youcompleteme
python-dev \  
tmux 
RUN pip install --upgrade neovim
RUN mkdir /root/Software 
WORKDIR /root/Software
RUN git clone https://github.com/karenyyng/dotFiles.git
WORKDIR ./dotFiles
RUN git checkout linux 

### vim specific settings 
RUN mkdir -p /root/.config/nvim 
RUN mv init.vim /root/.config/nvim/init.vim 
RUN ln -s /root/.config/nvim/init.vim /root/.vimrc
RUN curl -fLo /root/.local/share/nvim/site/autoload/plug.vim --create-dirs \
https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
RUN nvim +PlugInstall +qall
WORKDIR /root/.config/nvim/plug/YouCompleteMe/
RUN /root/.config/nvim/plug/YouCompleteMe/install.py --clang-completer
WORKDIR /root/.config/nvim/plug/python-mode
RUN git checkout tags/0.9.0
RUN pip install --upgrade pylint pyflakes pep8

### copy over other settings
WORKDIR /root/Software/dotFiles
RUN mv /root/Software/dotFiles/.tmux.conf /root/.tmux.conf
RUN git clone https://github.com/tmux-plugins/tmux-resurrect /root/Software/tmux-resurrect
WORKDIR /root

