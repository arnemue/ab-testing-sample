import logging
import requests
import azure.functions as func

NAME_DICT = {
    "arne": "model1",
    "basak": "model2"
}



def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Python HTTP trigger function processed a request.')

    name = req.params.get('name')
    if not name:
        try:
            req_body = req.get_json()
        except ValueError:
            pass
        else:
            name = req_body.get('name')

    if name:
        model_version = NAME_DICT.get(name, "model1")
        # api-endpoint
        URL = f"https://{model_version}.k8s.arnemue.de"
        # sending get request and saving the response as response object
        r = requests.get(url = URL)

        data = r.json()

        group = data["Group"]

        return func.HttpResponse(f"Hello, {name}. This HTTP triggered function executed successfully and the group is {group}.")
    else:
        return func.HttpResponse(
             "This HTTP triggered function executed successfully. Pass a name in the query string or in the request body for a personalized response.",
             status_code=200
        )
