FROM contino/aws-cli

# timezone
RUN apk add tzdata \
    && cp -r -f /usr/share/zoneinfo/Australia/NSW /etc/localtime

# AMS Install
COPY lib/ams /opt/app/lib/
WORKDIR /opt/app/lib
RUN ./AWSManagedServices_InstallCLI.sh
WORKDIR /opt/app

# pip for boto - for Ansible
RUN apk add --no-cache python3 && \
    python3 -m ensurepip && \
    rm -r /usr/lib/python*/ensurepip && \
    pip3 install --upgrade pip setuptools && \
    if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip ; fi && \
    if [[ ! -e /usr/bin/python ]]; then ln -sf /usr/bin/python3 /usr/bin/python; fi && \
    rm -r /root/.cache

# boto - for Ansible
RUN pip3 install boto
RUN pip3 install boto3

# ansible
RUN apk add ansible



