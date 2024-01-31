# Use an official Python runtime as a parent image
FROM python:3.9-slim

RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    software-properties-common \
    git \
    && rm -rf /var/lib/apt/lists/*

RUN ls -a
RUN python --version
RUN pip3 install --upgrade pip setuptools wheel
RUN pip3 install cmake
RUN pip install pyarrow==8.0.0

WORKDIR /usr/icdesbot

COPY ./requirements.txt .

RUN pip3 install --no-cache-dir -r requirements.txt

COPY ./ICD_GPT_chat.py .

EXPOSE 8501

ENTRYPOINT ["streamlit", "run"]

CMD ["ICD_GPT_chat.py"]
