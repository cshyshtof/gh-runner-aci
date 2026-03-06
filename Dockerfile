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
    python3 -m pip install --no-cache-dir -r requirements.txt

FROM python:3.12-slim

LABEL version="1.1.0" description="ACI Automation Image"

ARG USER_ID=1001
ARG GROUP_ID=1001

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    ANSIBLE_COLLECTIONS_PATH=/usr/share/ansible/collections \
    ANSIBLE_PYTHON_INTERPRETER=/usr/local/bin/python3

RUN groupadd -g ${GROUP_ID} automation && \
    useradd -u ${USER_ID} -g automation -m -s /bin/bash automation

WORKDIR /automation

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    openssh-client \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /usr/local /usr/local

COPY requirements.yml .
RUN mkdir -p ${ANSIBLE_COLLECTIONS_PATH} && \
    ansible-galaxy collection install -r requirements.yml -p ${ANSIBLE_COLLECTIONS_PATH} && \
    chown -R automation:automation ${ANSIBLE_COLLECTIONS_PATH}

RUN mkdir -p /automation/.ansible && \
    chown -R automation:automation /automation

USER automation

RUN ansible --version && ansible-galaxy collection list

CMD ["/bin/bash"]
