FROM amazonlinux

WORKDIR /
RUN yum update -y

# Install Python 3.7
RUN yum install python3 zip -y

# Install Python packages
RUN mkdir /packages
COPY requirements.txt /packages/requirements.txt
RUN mkdir -p /packages/opencv-python-3.7/python/lib/python3.7/site-packages
RUN pip3.7 install -r /packages/requirements.txt -t /packages/opencv-python-3.7/python/lib/python3.7/site-packages

# Create zip files for Lambda Layer deployment
WORKDIR /packages/opencv-python-3.7/
RUN zip -r9 /packages/opencv-python37.zip .
WORKDIR /packages/
RUN rm -rf /packages/opencv-python-3.7/
