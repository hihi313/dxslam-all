FROM osrf/ros:noetic-desktop-full

ENV TZ=Etc/UTC
ARG DEBIAN_FRONTEND=noninteractive
ARG ROOT_PWD=root
ARG APT_PKGS=apt_packages.txt
ARG PY_PKGS=requirements.txt

USER root
# Set root password
RUN echo 'root:${ROOT_PWD}' | chpasswd

# Install things here
WORKDIR /tmp

# Set up OpenVINO repo
# The key cannot download via wget
COPY ./GPG-PUB-KEY-INTEL-OPENVINO-2021 .
RUN apt-key add GPG-PUB-KEY-INTEL-OPENVINO-2021 \
    && echo "deb https://apt.repos.intel.com/openvino/2021 all main" | sudo tee /etc/apt/sources.list.d/intel-openvino-2021.list
# Install 
RUN apt update 
COPY ./${APT_PKGS} .
RUN xargs apt install --yes --no-install-recommends < ${APT_PKGS} \
    && apt clean \
    && rm -rf /var/lib/apt/lists/*
    

# Using latest pip (this is the only working way I tried)
# ADD https://bootstrap.pypa.io/get-pip.py .
# Install python packages
COPY ./${PY_PKGS} .
RUN python3 -m pip install --no-cache-dir --requirement ${PY_PKGS}

# Install Pangolin
RUN git clone --recursive --branch v0.8 --single-branch https://github.com/stevenlovegrove/Pangolin.git \
    && cd Pangolin \
    && mkdir build \
    && cd build \
    && cmake -D CMAKE_BUILD_TYPE=RELEASE -GNinja ../ \
    && ninja \
    && ninja install

# Install OpenCV
RUN git clone --branch 4.4.0 --single-branch https://github.com/opencv/opencv.git \
    && cd opencv \
    && mkdir build \
    && cd build \
    && cmake -D CMAKE_BUILD_TYPE=RELEASE \
    -D BUILD_TIFF=ON \
    -D WITH_CUDA=ON \
    -D ENABLE_AVX=OFF \
    -D WITH_OPENGL=OFF \
    -D WITH_OPENCL=OFF \
    -D WITH_IPP=OFF \
    -D WITH_TBB=ON \
    -D BUILD_TBB=ON \
    -D WITH_EIGEN=ON \
    -D WITH_V4L=OFF \
    -D WITH_VTK=OFF \
    -D BUILD_TESTS=OFF \
    -D BUILD_PERF_TESTS=OFF \
    -D OPENCV_GENERATE_PKGCONFIG=ON \
    -GNinja \
    ../ \
    && ninja \
    && ninja install

# Clean up
RUN rm -rf /tmp/* /var/tmp/*

# Set up env
COPY ./entrypoint.sh /tmp/
ENTRYPOINT ["/tmp/entrypoint.sh"]

WORKDIR /app

CMD ["bash"]