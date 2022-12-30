FROM ubuntu:18.04
ARG SOLC=0.5.12

# install basic packages
RUN apt-get update && apt-get install -y\
    software-properties-common\
    locales

# set correct locale
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# install tools
RUN apt-get update &&\
        apt-get -y install\
        wget\
        gdebi

# install souffle
RUN wget https://github.com/souffle-lang/souffle/releases/download/1.6.2/souffle_1.6.2-1_amd64.deb -O /tmp/souffle.deb &&\
        gdebi --n /tmp/souffle.deb

# install graphviz and pip
RUN apt-get update && apt-get -y install\
        graphviz \
        python3.7 \
        python3-pip \
	curl

# install the required solc version
RUN curl -L https://github.com/ethereum/solidity/releases/download/v$SOLC/solc-static-linux > /usr/bin/solc-$SOLC && \
    chmod +x /usr/bin/solc-$SOLC && \
    ln -s /usr/bin/solc-$SOLC /usr/local/bin/solc

COPY requirements.txt /requirements.txt

WORKDIR /sec

# copy and compile securify
COPY . /sec
ENV PYTHONPATH /sec

# install securify requirements
RUN python3.7 setup.py install && python3.7 -m pip install --user -r /requirements.txt && python3.7 -m pip install requests

RUN cd /sec/securify/staticanalysis/libfunctors/ && ./compile_functors.sh

RUN cd /sec/securify/staticanalysis/souffle_analysis && \
        souffle --dl-program=../dl-program \
        --fact-dir=/sec/securify/staticanalysis/facts_in \
        --output-dir=/sec/securify/staticanalysis/facts_out \
        -L../libfunctors -w analysis.dl


ENV LD_LIBRARY_PATH /sec/securify/staticanalysis/libfunctors

# Check that everything works and create a cache of the available patterns
# Should be removed
RUN cd /sec/securify/ && securify staticanalysis/testContract.sol

ENTRYPOINT ["python3.7", "securify/__main__.py"]
