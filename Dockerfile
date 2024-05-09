FROM python:3.12.2-slim-bookworm
LABEL maintainer="Winifred Igboama"

ENV PIP_DISABLE_PIP_VERSION_CHECK 1
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

ARG UID=1000
ARG GID=1000
ARG APP_USER=appuser

RUN groupadd -g "${GID}" ${APP_USER} \
    && useradd --no-create-home --no-log-init -u "${UID}" -g "${GID}" ${APP_USER} \
    && mkdir -p /app \
    && chown ${APP_USER}:${APP_USER} -R /app

COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
COPY --chown=${APP_USER}:${APP_USER} ./app ./app

WORKDIR /app
EXPOSE 8000

ARG DEV=false

ENV VIRTUAL_ENV=/opt/venv
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

RUN set -ex && \
    BUILD_DEPS=" \
    build-essential \
    python3-dev \
    postgresql-server-dev-all \
    " && \
    apt-get update && \ 
    apt-get install -y --no-install-recommends libpq-dev && \
    apt-get install -y --no-install-recommends $BUILD_DEPS && \
    \
    pip install --upgrade pip && \
    pip install -r /tmp/requirements.txt && \
    \
    if [ $DEV = "true" ]; \
    then pip install -r /tmp/requirements.dev.txt;  \
    fi &&  \
    \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false $BUILD_DEPS && \
    rm -rf /tmp && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean


USER ${APP_USER}
