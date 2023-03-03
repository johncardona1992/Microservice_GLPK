# Set the base image to Ubuntu
FROM ubuntu:latest

# Switch to root for install
USER root

# Install wget and Node.js version 19.x
RUN apt-get update -y && apt-get install -y \
	wget \
	build-essential \
	--no-install-recommends \
	&& rm -rf /var/lib/apt/lists/* \
    && wget -qO- https://deb.nodesource.com/setup_19.x | bash - \
    && apt-get install -y nodejs

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

# sudo docker run --memory="3g" --memory-swap="4g" -ti --rm <imageId> /bin/bash

USER user

