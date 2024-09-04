FROM quay.io/nf-core/ubuntu:20.04

ARG SAMTOOLS_VERSION=1.15 
ARG BCFTOOLS_VERSION=1.15
ARG HTSLIB_VERSION=1.15
ARG TRIMMOMATIC_VERSION=0.39
ARG BBMAP_VERSION=38.96
ARG PICARD_VERSION=2.26.11
ARG SEQKIT_VERSION=2.1.0
ARG IVAR_VERSION=1.3.1
ARG SEQTK_VERSION=1.3

ENV DEBIAN_FRONTEND=noninteractive 
ENV PATH=$PATH:/opt/bbmap
ENV TRIMMOMATIC=/usr/local/bin/trimmomatic.jar
ENV PICARD=/usr/local/bin/picard.jar
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib

RUN apt-get update && apt-get install -y \
    openjdk-11-jdk bc python3 wget libncurses5-dev bzip2 gcc g++ make zlib1g-dev libbz2-dev liblzma-dev unzip autoconf\
    # ---------- 
    # samtools
    && cd /tmp \
    && wget https://github.com/samtools/samtools/releases/download/${SAMTOOLS_VERSION}/samtools-${SAMTOOLS_VERSION}.tar.bz2 \
    && tar xjvf samtools-${SAMTOOLS_VERSION}.tar.bz2 \
    && cd samtools-${SAMTOOLS_VERSION} \
    && ./configure \
    && make \
    && make install \
    # ---------- 
    # bcftools
    && cd /tmp \
    && wget https://github.com/samtools/bcftools/releases/download/${BCFTOOLS_VERSION}/bcftools-${BCFTOOLS_VERSION}.tar.bz2 \
    && tar xjvf bcftools-${BCFTOOLS_VERSION}.tar.bz2 \
    && cd bcftools-${BCFTOOLS_VERSION} \
    && ./configure \
    && make \
    && make install \
    # ---------- 
    # trimmomatic
    && cd /tmp \
    && wget http://www.usadellab.org/cms/uploads/supplementary/Trimmomatic/Trimmomatic-${TRIMMOMATIC_VERSION}.zip \
    && unzip Trimmomatic-${TRIMMOMATIC_VERSION}.zip \
    && mv Trimmomatic-${TRIMMOMATIC_VERSION}/trimmomatic-${TRIMMOMATIC_VERSION}.jar /usr/local/bin/trimmomatic.jar \
    # ---------- 
    # bbmap
    && cd /tmp \
    && wget --no-check-certificate https://sourceforge.net/projects/bbmap/files/BBMap_${BBMAP_VERSION}.tar.gz/download -O BBMap_${BBMAP_VERSION}.tar.gz \
    && tar xzvf BBMap_${BBMAP_VERSION}.tar.gz \
    && mv bbmap /opt \
    # ---------- 
    # picard
    && cd /tmp \
    && wget https://github.com/broadinstitute/picard/releases/download/${PICARD_VERSION}/picard.jar \
    && mv picard.jar /usr/local/bin \
    # ---------- 
    # seqkit
    && cd /tmp \
    && wget https://github.com/shenwei356/seqkit/releases/download/v${SEQKIT_VERSION}/seqkit_linux_amd64.tar.gz \
    && tar xzvf seqkit_linux_amd64.tar.gz \
    && mv seqkit /usr/local/bin \
    # ---------- 
    # ivar
    && cd /tmp \
    && wget https://github.com/samtools/htslib/releases/download/${HTSLIB_VERSION}/htslib-${HTSLIB_VERSION}.tar.bz2 \
    && tar xjvf htslib-${HTSLIB_VERSION}.tar.bz2 \
    && cd htslib-${HTSLIB_VERSION} \
    && ./configure \
    && make \
    && make install \
    && cd /tmp \
    && wget https://github.com/andersen-lab/ivar/archive/refs/tags/v${IVAR_VERSION}.tar.gz \
    && tar xzvf v${IVAR_VERSION}.tar.gz \
    && cd ivar-${IVAR_VERSION} \
    && ./autogen.sh \
    && ./configure \
    && make \
    && make install \
    # ---------- 
    # seqtk
    && cd /tmp \
    && wget https://github.com/lh3/seqtk/archive/refs/tags/v${SEQTK_VERSION}.tar.gz \ 
    && tar xzvf v${SEQTK_VERSION}.tar.gz \ 
    && cd seqtk-${SEQTK_VERSION} \ 
    && make \
    && mv seqtk /usr/local/bin \ 
    # ----------
    # Clean up
    && apt autoremove -y wget libncurses5-dev bzip2 gcc g++ make zlib1g-dev libbz2-dev liblzma-dev unzip autoconf \
    && rm -rf /var/lib/apt/lists/* /tmp/*
   
CMD ["bash"]
