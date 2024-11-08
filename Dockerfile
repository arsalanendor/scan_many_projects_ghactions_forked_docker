# Use Ubuntu base image for linux/amd64
FROM ubuntu:latest

# Set environment variables for Scala and SBT versions
ARG SCALA_VERSION=2.13.8
ARG ENDORCTL_VERSION=v1.6.638

# Set environment variables
ENV SCALA_HOME=/usr/share/scala
ENV SBT_HOME=/usr/share/sbt
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV PATH=$PATH:$SCALA_HOME/bin:$SBT_HOME/bin:$JAVA_HOME/bin

# Install ca-certificates separately to prevent errors
RUN apt-get update && \
    apt-get install -y ca-certificates && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Add repositories for Yarn and SBT, and install dependencies
RUN apt-get update && \
    apt-get install -y curl software-properties-common apt-transport-https gnupg && \
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    echo "deb https://repo.scala-sbt.org/scalasbt/debian all main" | tee /etc/apt/sources.list.d/sbt.list && \
    curl -sL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x2EE0EA64E40A89B84B2DF73499E82A75642AC823" | apt-key add - && \
    apt-get update && \
    apt-get install -y python3 openjdk-11-jdk maven gradle yarn git python3-pip sbt && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Scala
RUN curl -L -o scala-${SCALA_VERSION}.deb https://downloads.lightbend.com/scala/${SCALA_VERSION}/scala-${SCALA_VERSION}.deb && \
    dpkg -i scala-${SCALA_VERSION}.deb && \
    rm scala-${SCALA_VERSION}.deb && \
    apt-get clean

# Verify installations
RUN java -version && \
    python3 --version && \
    sbt --version && \
    scala -version

# Copy and set entrypoint for shell script
COPY run-shell-script /usr/local/bin/run-shell-script
RUN chmod +x /usr/local/bin/run-shell-script
ENTRYPOINT ["/usr/local/bin/run-shell-script"]