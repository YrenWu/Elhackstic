FROM debian:latest

# Install prerequisites
RUN apt-get update && apt-get install -y curl

CMD /bin/bash