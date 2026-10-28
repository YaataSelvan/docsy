FROM python:3.13-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends git graphviz make \
    && rm -rf /var/lib/apt/lists/*

RUN git config --global --add safe.directory /work

RUN pip install --no-cache-dir uv

ENV UV_PROJECT_ENVIRONMENT=/opt/venv
ENV PATH="/opt/venv/bin:$PATH"

WORKDIR /app
COPY . .

RUN uv sync --locked --no-dev --no-install-project

WORKDIR /work

CMD ["sphinx-build", "--version"]
