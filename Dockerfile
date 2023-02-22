FROM osrf/ros:noetic-desktop-full

ENV TZ=Etc/UTC
ARG DEBIAN_FRONTEND=noninteractive
ARG ROOT_PWD=root

USER root
# Set root password
RUN echo 'root:${ROOT_PWD}' | chpasswd

# Install things here
WORKDIR /tmp

# Install 
RUN apt update 
COPY ./apt_packages.txt .
RUN xargs apt install --yes --no-install-recommends < apt_packages.txt \
    && apt clean \
    && rm -rf /var/lib/apt/lists/*

# Python packages
COPY ./requirements.txt .
RUN pip3 install --no-cache-dir --requirement requirements.txt

# Install Pangolin
RUN git clone --recursive --branch v0.8 --single-branch https://github.com/stevenlovegrove/Pangolin.git \
    && cd Pangolin \
    && mkdir build \
    && cd build \
    && cmake -D CMAKE_BUILD_TYPE=RELEASE -GNinja ../\
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
# RUN echo "source /opt/ros/noetic/setup.bash" >> ~/.bashrc

WORKDIR /app

CMD bash 