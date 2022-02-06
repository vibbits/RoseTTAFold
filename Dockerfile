FROM nvcr.io/nvidia/cuda:11.3.0-cudnn8-runtime-ubuntu20.04
ARG ROSETTACOMMONS_CONDA_USERNAME
ARG ROSETTACOMMONS_CONDA_PASSWORD

RUN apt-get update

RUN apt-get install -y wget libgomp1 unzip && rm -rf /var/lib/apt/lists/*

RUN wget -q \
    https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
    && bash Miniconda3-latest-Linux-x86_64.sh -b -p /var/conda\
    && rm -f Miniconda3-latest-Linux-x86_64.sh

ENV PATH /var/conda/bin:$PATH

RUN conda --version

COPY . /RoseTTaFold
WORKDIR /RoseTTaFold

RUN conda env create -q -f RoseTTAFold-linux.yml
RUN conda env create -q -f folding-linux.yml

RUN conda config --add channels https://${ROSETTACOMMONS_CONDA_USERNAME}:${ROSETTACOMMONS_CONDA_PASSWORD}@conda.graylab.jhu.edu
#installing pyrosetta into a base image so it gets cached between builds
RUN conda install -n folding pyrosetta=2021.38

RUN wget -q https://files.ipd.uw.edu/pub/RoseTTAFold/weights.tar.gz
RUN tar xfz weights.tar.gz
RUN ./install_dependencies.sh

ENV PATH /RoseTTaFold:$PATH

WORKDIR /tmp
