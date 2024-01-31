# icd-elastic-bot
speak with your data!

create a `.env` file with following data in project's root folder

```
STACK_VERSION=8.10.1

# watsonx.ai api url, (please make sure of the region):
API_URL=https://us-south.ml.cloud.ibm.com
API_KEY=ibm_api_key
PROJECT_ID=watsonx_project_id

ELASTIC_HOST=https://awesome_host:awesome_port
ELASTIC_USERNAME=admin
ELASTIC_PASSWORD=awesome_password
ELASTIC_CA_CERTS=/path/to/ca.crt

# this should be the name of your index while creating web-crawler
ELASTIC_INDEX=search-bot

# you might need to increase memory for docker
MEM_LIMIT=1073741824
# no need to change, please export the ports and use
KIBANA_HOST=http://host.docker.internal
KIBANA_PORT=5601
SEARCH_HOST=http://host.docker.internal
SEARCH_PORT=3002
ENCRYPTION_KEY=super_secret
```

to run the server: `docker-compose up`

visit:
app at: `localhost:8501`
kibana at: `localhost:5601`
