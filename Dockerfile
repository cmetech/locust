FROM python:3.11-slim as base

FROM base as builder
RUN apt-get update && apt-get install -y --no-install-recommends git gcc pkg-config libssl-dev python3-dev default-libmysqlclient-dev && \
    rm -rf /var/lib/apt/lists/*

# there are no wheels for some packages (geventhttpclient?) for arm64/aarch64, so we need some build dependencies there
RUN if [ -n "$(arch | grep 'arm64\|aarch64')" ]; then apt install -y --no-install-recommends gcc python3-dev; fi
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
COPY . /build
RUN pip install /build/
RUN pip install --no-cache-dir --upgrade -r /build/requirements.txt

FROM base
COPY --from=builder /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
# turn off python output buffering
ENV PYTHONUNBUFFERED=1
RUN useradd --create-home locust
# ensure correct permissions
RUN chown -R locust /opt/venv
USER locust
WORKDIR /home/locust
EXPOSE 8089 5557
ENTRYPOINT ["locust"]
