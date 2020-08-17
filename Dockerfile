# FROM nvcr.io/nvidia/pytorch:19.12-py3
FROM ubuntu:18.04

RUN DEBIAN_FRONTEND=noninteractive \
    TZ=Eurpoe/London \
    apt-get update && apt-get install -y \
	git python3-pip software-properties-common wget && \
	rm -rf /var/lib/apt/lists/*

RUN pip3 install torch==1.6.0+cpu torchvision==0.7.0+cpu -f https://download.pytorch.org/whl/torch_stable.html

WORKDIR /app

# Copy U-2-Net.
COPY U-2-Net ./U-2-Net

#COPY u2net.pth ./U-2-Net/saved_models/u2net/u2net.pth

# Copy Resnet.
RUN mkdir /root/.torch && mkdir /root/.torch/models
RUN wget https://download.pytorch.org/models/resnet34-333f7ec4.pth -o /root/.torch/models/resnet34-333f7ec4.pth

# Install production dependencies.
COPY requirements.txt requirements.txt
RUN pip3 install --no-cache-dir -r requirements.txt

# Copy local code to the container image.
COPY *.py ./

# Set default port.
ENV PORT 80

# Run the web service using gunicorn.
CMD exec gunicorn --bind :$PORT --workers 1 main:app
