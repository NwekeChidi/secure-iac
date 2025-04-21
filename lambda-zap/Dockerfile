FROM public.ecr.aws/lambda/provided:al2

# ---- ZAP CLI + AWS CLI ----
RUN yum -y install java-17-amazon-corretto git tar gzip && \
  curl -L https://github.com/zaproxy/zaproxy/releases/download/v2.15.0/ZAP_2.15.0_Linux.tar.gz \
    | tar xz -C /opt && \
  ln -s /opt/ZAP_2.15.0/zap.sh /usr/local/bin/zap-cli

# ---- Lambda bootstrap ----
COPY entrypoint.sh /entrypoint.sh
COPY handler.py ./
RUN chmod +x /entrypoint.sh
CMD [ "handler.handler" ]