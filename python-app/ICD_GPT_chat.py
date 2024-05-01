import os
import logging

import streamlit as st
from ibm_watson_machine_learning.foundation_models.utils.enums import ModelTypes
from ibm_watson_machine_learning.foundation_models import Model as IBMModel
from elasticsearch import Elasticsearch

logging.basicConfig(level=logging.INFO)
api_key = os.getenv("API_KEY", None)
api_url = os.getenv("API_URL", None)
es_host = os.getenv("ELASTIC_HOST", None)
es_username = os.getenv("ELASTIC_USERNAME", None)
es_password = os.getenv("ELASTIC_PASSWORD", None)
es_index = os.getenv('ELASTIC_INDEX', None)
project_id = os.getenv('PROJECT_ID', None)


# Connect to Elastic Platinum formation
def es_connect():
    es = Elasticsearch(es_host,
                       ca_certs="/app/ca.crt",
                       basic_auth=(es_username, es_password)
                       )
    return es


def search(query_text):
    es = es_connect()
    # Ensure connection is established
    if not es.ping():
        logging.error("Failed to connect to Elasticsearch")
        return None, None

    # Elasticsearch query
    es_elser_query = {
        "text_expansion": {
            "ml.inference.title_expanded.predicted_value": {
                "model_id": ".elser_model_1",
                "model_text": query_text,
            }
        }
    }

    fields = ["title", "body_content", "url"]
    try:
        resp = es.search(index=es_index, query=es_elser_query, fields=fields, size=10, source=False)
        logging.info(f"Elasticsearch response: {resp}")

        if resp['hits']['hits']:
            body = resp['hits']['hits'][0]['fields'].get('body_content', [None])[0]
            url = resp['hits']['hits'][0]['fields'].get('url', [None])[0]
            return body, url
        else:
            print("No results found")
            return None, None
    except Exception as e:
        logging.error(f"Error executing Elasticsearch query: {e}")
        return None, None


def truncate_text(text, max_tokens):
    tokens = text.split()
    if len(tokens) <= max_tokens:
        return text

    return ' '.join(tokens[:max_tokens])


# Generate a response from watsonx/BAM based on the given prompt
def chat_gpt_ibm(prompt, max_tokens=1024):
    my_credentials = {
        "url": api_url,
        "apikey": api_key
    }
    model_id = ModelTypes.LLAMA_2_70B_CHAT
    gen_parms = {
        "decoding_method": "sample",
        "max_new_tokens": 4096,
        "min_new_tokens": 0,
        "random_seed": 87878,
        "stop_sequences": [],  # Add specific sequences here if needed
        "temperature": 0.5
        # "top_k": 50,
        # "top_p": 0.9,
        # "repetition_penalty": 1.2
    }
    global project_id
    space_id = None
    verify = False
    ibm_model = IBMModel(model_id, my_credentials, gen_parms, project_id, space_id, verify)
    gen_parms_override = None

    tx = truncate_text(prompt, max_tokens)
    generated_response = ibm_model.generate(tx, gen_parms_override)
    return generated_response["results"][0]["generated_text"]


def prompt_template(context, question_text):
    return (
            'Generate the next agent response without grammar mistakes as a techical architect and return steps  in proper format highlight code or commands whenever you find any and without repeating given the following content. If the question is unanswerable, say "unanswerable".\n\n, Convert the response into markdown'
            + "Content:\n\n"
            + f"{context}\n\n"
            + "##\n\n"
            + f"User: {question_text}\n\n"
            + "Agent: "
    )


st.write(
    "Hi, I am a chat bot. Ask me any question you like and I will try to answer it!")
query = st.chat_input("You: ")
with st.chat_message("user"):
    # Generate and display response on form submission
    negResponse = "unanswerable "
    if query:
        resp, url = search(query)
        prompt = prompt_template(resp, query)

        with st.status(f"Running your query"):
            logging.info("Application started")
            answer = chat_gpt_ibm(prompt)
            # TODO:
            if negResponse in answer:
                st.write(f"BOT: {answer.strip()}")
            else:
                st.markdown(f"BOT: {answer}\n\nDocs: {url}")

