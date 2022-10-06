import datetime
import logging

import azure.functions as func

def main(mytimer: func.TimerRequest) -> None:
    utc_timestamp = datetime.datetime.utcnow().replace(
        tzinfo=datetime.timezone.utc).isoformat()

    if mytimer.past_due:
        logging.info('The timer is past due!')

    properties = {'custom_dimensions': {'accuracy': 0.9, 'score': 0.7}}

    logging.info('Python timer trigger function ran at %s', utc_timestamp)

    logging.info("action", extra=properties)
