FROM python:3.12.2-slim-bookworm
LABEL maintainer="Winifred Igboama"

ENV PIP_DISABLE_PIP_VERSION_CHECK 1
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

ARG UID=1000
ARG GID=1000
ARG APP_USER=appuser

# Create appuser with specified UID and GID
RUN groupadd -g "${GID}" ${APP_USER} \
    && useradd --no-create-home --no-log-init -u "${UID}" -g "${GID}" ${APP_USER} \
    && mkdir -p /app

# Copy requirements and application code
COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
COPY ./app /app

WORKDIR /app

# Create virtual environment
ENV VIRTUAL_ENV=/opt/venv
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Install dependencies
ARG DEV=false
RUN set -ex && \
    BUILD_DEPS=" \
    build-essential \
    python3-dev \
    postgresql-server-dev-all \
    " && \
    apt-get update && \ 
    apt-get install -y --no-install-recommends libpq-dev && \
    apt-get install -y --no-install-recommends $BUILD_DEPS && \
    pip install --upgrade pip && \
    pip install -r /tmp/requirements.txt && \
    if [ $DEV = "true" ]; then pip install -r /tmp/requirements.dev.txt; fi && \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false $BUILD_DEPS && \
    rm -rf /tmp && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean

RUN mkdir -p /vol/web/media && \
    mkdir -p /vol/web/static

# Set ownership and permissions
RUN chown -R ${APP_USER}:${APP_USER} /app && \
    chown -R ${APP_USER}:${APP_USER} /vol && \
    chmod -R 755 /vol

# Switch to non-root user
USER ${APP_USER}

# Expose port 8000
EXPOSE 8000
