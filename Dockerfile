# Set the base image to Ubuntu
FROM ubuntu:22.04

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
#    && gpg --verify glpk-4.65.tar.gz.sig
#    #&& gpg --keyserver keys.gnupg.net --recv-keys 5981E818

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
    && chown -R user:user $HOME \
    && chmod -R a+rwx $HOME

# switch back to user
WORKDIR $HOME
# copy node configuration
COPY package.json package-lock.json* ./
# install Node application
RUN npm install
# copy model and parameters
COPY . $HOME
# Change ownership to user
RUN chown -R user:user $HOME

USER user

# ejecutar la API.
