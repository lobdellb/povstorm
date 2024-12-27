from google.cloud import pubsub

from flask import Flask, request
from google.cloud import storage

import base64
import os
import json
import subprocess
import glob
import shutil

import utils  # doesn't work yet

import models

# Imports the Cloud Logging client library
import google.cloud.logging



config = models.Configuration()


# Instantiates a client
client = google.cloud.logging.Client(project=config.GCP_PROJECT)

# Retrieves a Cloud Logging handler based on the environment
# you're running in and integrates the handler with the
# Python logging module. By default this captures all logs
# at INFO level and higher
client.setup_logging()

import logging

gcs_client = storage.Client( project=config.GCP_PROJECT )


# Next things to do:
# - move models to the module
# - move utils to the module
# - pip install the module into this container
# - chop up the functions into testable functions
# - write tests



app = Flask(__name__)

    
# {
#     "message":
#     {
#         "data": "NA==",
#         "messageId": "12932279813934953",
#         "message_id": "12932279813934953",
#         "publishTime": "2024-11-09T20:35:41.602Z",
#         "publish_time": "2024-11-09T20:35:41.602Z"
#     },
#     "subscription": "projects/terraform-play-2/subscriptions/eventarc-us-central1-trigger-elmnfbt0-sub-951"
# }



def run_binary(cmd,cwd):
    # try:
        # Run the "bryce" binary and capture both stdout and stderr
    result = subprocess.run(
        cmd,
        capture_output=True,   # Captures both stdout and stderr
        text=True,             # Decodes output as text (string) instead of bytes
        check=False,            # Raises an error if exit code is non-zero
        cwd=cwd
    )
    
    if result.returncode != 0:
        logging.info( f"run_binary: return code was --{result.returncode}-- with stdout --{result.stdout}-- and stderr --{result.stderr}--")


    # Print or process result.stdout and result.stderr if needed
    return result.stdout, result.stderr, result.returncode
    
    # except subprocess.CalledProcessError as e:
    #     # If the command fails, you can handle the error here
    #     # print("An error occurred while running bryce.")
    #     # return None, e.stderr


@app.route("/health", methods=["GET"])
def health():
    return "Chuffed!", 200


# Inbound parameters 
# - GCS content shared - This will be fetched from GCS and loaded into the local FS just once.
# - GCS content bespoke - This will be fetched from GCS and loaded into the local FS each time.
# - Inline content - A JSON doc which contains files specific to this run.
# - Command to run
# - Local filename to offload
# - Offload GCS path
# - WorkUnit ID

# doc = {
#     "shared_gcs_content": ...,
#     "bespoke_gcs_content":...,
#     "inline_content": { "fn1": <base64encoded data>, "fn2": <base64encoded data> , ... }
#     "cmd": ..., 
#     "local_result_fns": ["fn1","fn2",...],
#     "offload_gcs_path": ...
# }



@app.route("/process_workunit", methods=["POST"])
def process_workunit():

    logging.info( "starting message handling")
    
    envelope = request.get_json()
    if not envelope:
        msg = "no Pub/Sub message received"
        print(f"error: {msg}")
        return f"Bad Request: {msg}", 400

    if not isinstance(envelope, dict) or "message" not in envelope:
        msg = "invalid Pub/Sub message format"
        print(f"error: {msg}")
        return f"Bad Request: {msg}", 400

    pubsub_message = envelope["message"]
    data = pubsub_message["data"].decode("utf-8")

    work_unit = models.WorkUnit.parse_raw( data )

    # name = "World"
    # if isinstance(pubsub_message, dict) and "data" in pubsub_message:
    #     name = base64.b64decode(pubsub_message["data"]).decode("utf-8").strip()

    logging.info( f"type of doc is {type(doc)}")
    logging.info( f"povray_runner_doc: {doc}")


    # Steps
    # 0) Create a private/temp path in the local filesystem for doing everything for this WorkUnit.
    # 1) Softlink the shared resources from GCS into the temporary path for the WorkUnit.
    # 2) Softlink the output path from GCS into the temporary path for the WorkUnit.
    # 3) Go through the inline_resource dictionary and drop those files into the workspace directory.
    # 4) Run the povray (or other) command.
    # 5) Drop the work files.

    # (0)
    workspace_path = f"./workunit-{work_unit.job_id}-{work_unit.work_unit_id}/"

    shared_resource_local_path = os.path.join( config.MOUNT_PATH, work_unit.bespoke_resource_gcs_prefix )

    # (1) 
    os.symlink( work_unit.shared_resource_gcs_prefix, os.path.join( workspace_path, "shared" ) )

    # (2)
    os.symlink( work_unit.offload_gcs_prefix, os.path.join( workspace_path, "output" ) )

    # (3)
    for resource_fn in work_unit.inline_resource:
        with open( resource_fn, "wb" ) as fp:
            fp.write( base64.b64decode( work_unit.inline_resource[ resource_fn ] ) )

    # (4)
    # This should/must be configured to drop the result outputs in 
    stdout, stderr, returncode = run_binary( cmd=work_unit.cmd , cwd=workspace_path )

    if not returncode == 0:
        raise Exception(f"povstorm:process_workunit:call to cmd: failed with error code --{returncode}--, stderr --{stderr}--, and stdout --{stdout}--.")
    else:
        logging.info( f"povstorm:process_workunit:call to cmd: suceeded with stderr --{stderr}--, and stdout --{stdout}--." )


    # (5)
    utils.remove_recursively( workspace_path )


    logging.info("finished")

    return ( "povray_runner_doc: " , 204)











