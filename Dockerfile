FROM nvidia/cuda:8.0-cudnn6-devel-ubuntu16.04

ENV CONDA_DIR=/opt/conda \
    SHELL=/bin/bash \
    NB_USER=jovyan \
    NB_UID=1000 \
    NB_GID=100 \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8
ENV PATH=$CONDA_DIR/bin:$PATH \
    HOME=/home/$NB_USER

COPY fix-permissions /usr/local/bin/fix-permissions
RUN chmod +x /usr/local/bin/fix-permissions

ENV DEBIAN_FRONTEND noninteractive
RUN set -x \
    && apt-get update -y \
    && apt-get install -y --no-install-recommends \
        wget \
        bzip2 \
        ca-certificates \
        sudo \
        locales \
        fonts-liberation \
        build-essential \
        emacs \
        git \
        inkscape \
        jed \
        libsm6 \
        libxext-dev \
        libxrender1 \
        lmodern \
        pandoc \
        python-dev \
        texlive-fonts-extra \
        texlive-fonts-recommended \
        texlive-generic-recommended \
        texlive-latex-base \
        texlive-latex-extra \
        texlive-xetex \
        vim \
        unzip \
        libav-tools \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN set -x \
    && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
    && locale-gen

RUN set -x \
    && wget --quiet https://github.com/krallin/tini/releases/download/v0.10.0/tini \
    && echo "1361527f39190a7338a0b434bd8c88ff7233ce7b9a4876f3315c22fce7eca1b0 *tini" | sha256sum -c - \
    && mv tini /usr/local/bin/tini \
    && chmod +x /usr/local/bin/tini

RUN set -x \
    && useradd -m -s /bin/bash -N -u $NB_UID $NB_USER \
    && mkdir -p $CONDA_DIR \
    && chown $NB_USER:$NB_GID $CONDA_DIR \
    && fix-permissions $HOME \
    && fix-permissions $CONDA_DIR

USER $NB_USER

RUN set -x \
    && mkdir /home/$NB_USER/work \
    && fix-permissions /home/$NB_USER

ENV MINICONDA_VERSION 4.3.21
RUN set -x \
    && cd /tmp \
    && wget --quiet https://repo.continuum.io/miniconda/Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh \
    && echo "c1c15d3baba15bf50293ae963abef853 *Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh" | md5sum -c - \
    && /bin/bash Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh -f -b -p $CONDA_DIR \
    && rm Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh \
    && $CONDA_DIR/bin/conda config --system --prepend channels conda-forge \
    && $CONDA_DIR/bin/conda config --system --set auto_update_conda false \
    && $CONDA_DIR/bin/conda config --system --set show_channel_urls true \
    && $CONDA_DIR/bin/conda update --all --quiet --yes \
    && conda clean -tipsy \
    && fix-permissions $CONDA_DIR

RUN set -x \
    &&conda install --quiet --yes \
        'notebook=5.1.*' \
        'jupyterhub=0.8.*' \
        'jupyterlab=0.27.*' \
    && conda clean -tipsy \
    && fix-permissions $CONDA_DIR

RUN set -x \
    && conda install --quiet --yes \
        'notebook=5.1.*' \
        'jupyterhub=0.8.*' \
        'jupyterlab=0.27.*' \
    && conda clean -tipsy \
    && fix-permissions $CONDA_DIR

RUN set -x \
    && conda install --quiet --yes \
        'nomkl' \
        'ipywidgets=7.0*' \
        'pandas=0.19*' \
        'numexpr=2.6*' \
        'matplotlib=2.0*' \
        'scipy=0.19*' \
        'seaborn=0.7*' \
        'scikit-learn=0.18*' \
        'scikit-image=0.12*' \
        'sympy=1.0*' \
        'cython=0.25*' \
        'patsy=0.4*' \
        'statsmodels=0.8*' \
        'cloudpickle=0.2*' \
        'dill=0.2*' \
        'numba=0.31*' \
        'bokeh=0.12*' \
        'sqlalchemy=1.1*' \
        'hdf5=1.8.17' \
        'h5py=2.6*' \
        'vincent=0.4.*' \
        'beautifulsoup4=4.5.*' \
        'protobuf=3.*' \
        'xlrd' \
        'tensorflow-gpu=1.3*' \
        'keras=2.0*' \
    && conda remove --quiet --yes --force qt pyqt \
    && conda clean -tipsy \
    && jupyter nbextension enable --py widgetsnbextension --sys-prefix \
    && fix-permissions $CONDA_DIR

USER root

EXPOSE 8888
WORKDIR $HOME

ENTRYPOINT ["tini", "--"]
CMD ["start-notebook.sh"]

COPY start.sh /usr/local/bin/
COPY start-notebook.sh /usr/local/bin/
COPY start-singleuser.sh /usr/local/bin/
COPY jupyter_notebook_config.py /etc/jupyter/
RUN fix-permissions /etc/jupyter/

RUN cd /tmp && \
    git clone https://github.com/PAIR-code/facets.git && \
    cd facets && \
    jupyter nbextension install facets-dist/ --sys-prefix && \
    rm -rf facets && \
    fix-permissions $CONDA_DIR

ENV XDG_CACHE_HOME /home/$NB_USER/.cache/
RUN MPLBACKEND=Agg python -c "import matplotlib.pyplot" && \
    fix-permissions /home/$NB_USER

USER $NB_USER
