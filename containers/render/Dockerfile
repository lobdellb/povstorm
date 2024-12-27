# Use an official Python runtime as a parent image
FROM ubuntu:24.04

# Set the working directory in the container
WORKDIR /app


RUN apt update -y
RUN apt upgrade -y

RUN apt install -y curl autoconf python3-dev python3-pip python3 libboost-dev libboost-date-time-dev libboost-thread-dev zlib1g-dev libpng-dev libjpeg8-dev libtiff5-dev libopenexr-dev

RUN curl https://codeload.github.com/POV-Ray/povray/tar.gz/refs/tags/v3.7.0.10 -o povray.tgz
RUN tar -zxf povray.tgz

WORKDIR /app/povray-3.7.0.10/unix/

RUN ./prebuild.sh

WORKDIR /app/povray-3.7.0.10/

RUN ./configure COMPILED_BY="POVStorm"

RUN make

RUN make install


WORKDIR /app/


COPY requirements.txt ./

RUN pip3 install --no-cache-dir --break-system-packages -r requirements.txt

COPY ./src/* ./

CMD exec gunicorn --bind :8080 --workers 1 --threads 8 --timeout 0 main:app