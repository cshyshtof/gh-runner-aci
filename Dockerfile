FROM python:3.12-slim AS builder

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /build

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN python3 -m pip install --upgrade pip && \
    python3 -m pip install --prefix=/install ansible-core==2.16.0 -r requirements.txt

FROM python:3.12-slim

LABEL version="1.0.0"
LABEL description="ACI Automation Image"

RUN groupadd -g 1001 automation && \
    useradd -u 1001 -g automation -m -s /bin/bash automation

WORKDIR /automation

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    openssh-client \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /install /usr/local

COPY requirements.yml .
RUN mkdir -p /usr/share/ansible/collections && \
    ansible-galaxy collection install -r requirements.yml -p /usr/share/ansible/collections

RUN chown -R automation:automation /automation

USER automation

CMD ["/bin/bash"]

