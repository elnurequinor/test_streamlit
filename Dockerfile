#
# -- Base image
#
FROM ubuntu:latest as base
RUN apt-get update -y && \
    apt-get install -y python3-pip python3-dev && \
    pip3 install --upgrade pip

COPY ./requirements.txt /app/requirements.txt
WORKDIR /app
COPY . /app
RUN pip3 install -r requirements.txt

# Add a new group "radix-non-root-group" with group id 1000 
RUN groupadd -g 1000 py7-non-root-group

# Add a new user "radix-non-root-user" with user id 1000 and include in group
RUN useradd -u 1000 -g py7-non-root-group py7-non-root-user

#
# -- Dependencies
#
FROM base as dependencies
RUN pip install pylint
#
# Run tests and lint (Pylint)
#
#FROM dependencies as testing
#WORKDIR /app/src
#RUN python3 test.py
# RUN pylint streamlit-app.py

#
# Release image
#
FROM base as release
WORKDIR /app/src
EXPOSE 8501
USER 1000
ENTRYPOINT ["streamlit", "run"]
CMD ["app.py"]