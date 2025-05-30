FROM python:3.11
ARG UID=1000
ARG GID=1000
ARG USERNAME=python-user
ARG UPLOADS_FOLDER=/uploads

RUN groupadd -g "${GID}" "${USERNAME}" && \
    adduser --uid "${UID}" --gid "${GID}" --gecos "" --disabled-password "${USERNAME}" && \
    mkdir ${UPLOADS_FOLDER} && \
    chown ${USERNAME}:${USERNAME} ${UPLOADS_FOLDER}

USER ${USERNAME}
ENV PATH=/home/${USERNAME}/.local/bin:/usr/local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
WORKDIR /code

# Install production requirements
COPY requirements/requirements.txt requirements.txt
RUN pip install --no-cache-dir --upgrade -r requirements.txt

COPY ./app app
COPY ./alembic alembic
COPY ./alembic.ini alembic.ini
EXPOSE 8000
VOLUME ${UPLOADS_FOLDER}
CMD PYTHONUNBUFFERED=1 gunicorn --capture-output --worker-tmp-dir /dev/shm --workers=2 --threads=4 --worker-class=gthread --bind 0.0.0.0 app:app
