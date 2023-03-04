# Set the base image to Ubuntu
FROM ubuntu:latest

# Switch to root for install
USER root

# install Node js 19 
RUN apt-get update
RUN apt-get -y install curl gnupg
RUN curl -sL https://deb.nodesource.com/setup_19.x  | bash -
RUN apt-get -y install nodejs

# Install wget
RUN apt-get update -y && apt-get install -y \
	wget \
	build-essential \
	--no-install-recommends \
	&& rm -rf /var/lib/apt/lists/* 

# Install glpk from http
# instructions and documentation for glpk: http://www.gnu.org/software/glpk/
WORKDIR /user/local/

RUN wget http://ftp.gnu.org/gnu/glpk/glpk-4.65.tar.gz \
	&& tar -zxvf glpk-4.65.tar.gz

## Verify package contents
# RUN wget http://ftp.gnu.org/gnu/glpk/glpk-4.65.tar.gz.sig \
#	&& gpg --verify glpk-4.65.tar.gz.sig
#	#&& gpg --keyserver keys.gnupg.net --recv-keys 5981E818

WORKDIR /user/local/glpk-4.65
# install GLPK
RUN ./configure \
	&& make \
	&& make check \
	&& make install \
	&& make distclean \
	&& ldconfig \
	# Cleanup
	&& rm -rf /user/local/glpk-4.65.tar.gz \
	&& apt-get clean

#create a glpk user
ENV HOME /home/user
RUN useradd --create-home --home-dir $HOME user \
	&& chmod -R u+rwx $HOME \
	&& chown -R user:user $HOME

# switch back to user
WORKDIR $HOME
# copy model and parameters
COPY . $HOME
# install Node application
RUN npm install
# sudo docker run --memory="3g" --memory-swap="4g" -ti -name glpk_container --rm glpk_micro /bin/bash

USER user

