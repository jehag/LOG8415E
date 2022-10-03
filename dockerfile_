FROM ubuntu:latest

RUN apt update
RUN apt install python3 -y
RUN apt install python3-pip -y
RUN pip3 install requests

WORKDIR /usr/app/src

COPY script.py ./

CMD [ "python3", "./script.py"]