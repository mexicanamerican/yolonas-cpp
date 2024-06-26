# Dockerfile written by Uglješa Lukešević for YOLO-NAS CPP library (github.com/ukicomputers)
# Marked as Open Source project under GNU GPL-3.0 license
# NOTE: this Dockerfile DOES NOT support CUDA usage

FROM ubuntu:noble

# Install required packages
RUN apt update && \
    apt install -y build-essential \
                cmake \
                git \
                pkg-config && \
    rm -rf /var/lib/apt/lists/*

# Compile and install OpenCV
RUN git clone https://github.com/opencv/opencv
WORKDIR opencv/build
RUN cmake .. && \
    make -j$(nproc) && \
    make install && \
    rm -rf /opencv

# Compile and install yolonas-cpp library
RUN git clone https://github.com/ukicomputers/yolonas-cpp /yolonas-cpp
WORKDIR /yolonas-cpp
RUN bash install.bash

# Prepare models
RUN bash download_models.bash

# Build, launch the application & prepare ENVs
WORKDIR demo/docker
RUN bash build.bash

# ENV variables for setting up the detection
# Model and metadata pass will be supported in future versions because of expected labels
ENV model="/yolonas-cpp/models/yolonas/onnx/yolonas_s.onnx"
ENV metadata="/yolonas-cpp/models/yolonas/onnx/yolonas_s_metadata"
ENV source="/yolonas-cpp/models/yolonas/onnx/image.jpg"

CMD ["/yolonas-cpp/demo/docker/build/yolonas-demo"]
