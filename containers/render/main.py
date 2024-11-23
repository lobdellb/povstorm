from google.cloud import pubsub

from flask import Flask, request
from google.cloud import storage

import base64
import os
import json
import subprocess
import glob
import shutil

# Imports the Cloud Logging client library
import google.cloud.logging


# Instantiates a client
client = google.cloud.logging.Client()

# Retrieves a Cloud Logging handler based on the environment
# you're running in and integrates the handler with the
# Python logging module. By default this captures all logs
# at INFO level and higher
client.setup_logging()

import logging

gcs_client = storage.Client( project="terraform_play_2" )


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





@app.route("/", methods=["POST"])
def index():

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

    name = "World"
    if isinstance(pubsub_message, dict) and "data" in pubsub_message:
        name = base64.b64decode(pubsub_message["data"]).decode("utf-8").strip()


    # print( envelope )
    # print(f"Hello Bryce!")

    doc = json.loads( base64.b64decode(pubsub_message["data"]).decode("utf-8").strip() )

    logging.info( f"type of doc is {type(doc)}")
    logging.info( f"povray_runner_doc: {doc}")

    # {
    #     "output_fn": "frame_0506.png",
    #     "pov_cmd": "povray earth_moon.pov Output_File_Name=frame_0506.png",
    #     "before_inc_content": "\n    #declare earth_rotate_angle = 0.0;\n    ",
    #     "after_inc_content": "\nsphere {\n\t<15376.0, 0.0, 0.0>, moon_radius_km\n\ttexture {\n\t  pigment { \n\t  \t// color LightBlue\n        \n        //image_map {\n\t    //    png \"moon.png\" // one of the accepted file formats\n\t    //    map_type 1 // this is spherical wrapping\n\t    //}\n        \n        color Gray\n\t  }\n\t}\n\n\tfinish {\n\t  ambient rgb <0.35,0.35,0.35>\n\t}\n}\n",
    #     "package_gcs_uri": "gs://brycelobdell-terraform-play2-povray/earth_moon_source.tgz"
    #     package_gcs_bucket = "brycelobdell-terraform-play2-povray"
    # package_gcs_prefix = "earth_moon_source.tgz"
    # }

    # {
        # 'output_fn': 'frame_0506.png', 
        # 'pov_cmd': 'povray earth_moon.pov Output_File_Name=frame_0506.png', 
        # 'before_inc_content': '\n    #declare earth_rotate_angle = 0.0;\n    ', 'after_inc_content': '\nsphere {\n\t<15376.0, 0.0, 0.0>, moon_radius_km\n\ttexture {\n\t  pigment { \n\t  \t// color LightBlue\n        \n        //image_map {\n\t    //    png "moon.png" // one of the accepted file formats\n\t    //    map_type 1 // this is spherical wrapping\n\t    //}\n        \n        color Gray\n\t  }\n\t}\n\n\tfinish {\n\t  ambient rgb <0.35,0.35,0.35>\n\t}\n}\n', 
        # 'package_gcs_uri': 'gs://brycelobdell-terraform-play2-povray/earth_moon_source.tgz'}


	# fetch the package, unless it already exists

    if not os.path.isfile( "earth_moon/moon.png" ):

        logging.info("loading the pov source package into the fs")

        package_fn = "package.tgz"

        bucket = gcs_client.bucket( doc["package_gcs_bucket"] )
        blob = bucket.blob( doc["package_gcs_prefix"] )
        blob.download_to_filename( package_fn )

        # stdout,stderr,retval = run_binary( ["find", package_fn ], cwd=os.getcwd() )

        stdout,stderr,retval = run_binary( ["tar","-zxf", package_fn ], cwd=os.getcwd() )

        os.remove( package_fn )



        logging.info( f"cwd is {os.getcwd()}" )
        logging.info( "listing all files" )


        # ll_files is ['main.py', 'povray.tgz', 'requirements.txt', 'earth_moon', 'earth_moon/moon.png', 'earth_moon/1920px-Lambert_cylindrical_equal-area_projection_SW.jpg', 'earth_moon/earth_moon.pov', '__pycache__', '__pycache__/main.cpython-312.pyc']
        all_files = list( filter( lambda s : not s.startswith("povray-3.7.0.10" ) ,  glob.glob("**",recursive=True ) ) )

        logging.info( type( all_files ) )
        logging.info( f"all_files is {list( all_files )}" )
        logging.info( "done listing files" )


    # run povray

    povray_cwd = os.getcwd() + "/earth_moon/"

    # with open( "earth_moon/before_include.inc", "w" ) as fp_before_inc:
    #     fp_before_inc.write( doc["before_inc_content"] )

    # with open( "earth_moon/after_include.inc", "w" ) as fp_after_inc:
    #     fp_after_inc.write( doc["after_inc_content"] )

    # stdout, stderr, retval = run_binary(cmd=["find"],cwd=povray_cwd)

    # logging.info( f"stdout for find was --{stdout}--")
    # logging.info( f"stder for find was --{stderr}--")


    if os.path.isfile( "earth_moon/" + doc["scene_fn"] ):
        os.remove( "earth_moon/" + doc["scene_fn"]  )

    with open( "earth_moon/" + doc["scene_fn"], "w" ) as fp_scene: 
        fp_scene.write( doc["scene_content"] )


    logging.info( f"povray command was --{doc["pov_cmd"]}--")

    if os.path.isfile( povray_cwd  +  doc["output_fn"] ):
        os.remove( povray_cwd  +  doc["output_fn"]  )

    stdout, stderr, retval = run_binary(cmd=doc["pov_cmd"],cwd=povray_cwd)

    logging.info( f"stdout for povray was --{stdout}--")
    logging.info( f"stder for povray was --{stderr}--")


    bucket = gcs_client.bucket( doc["package_gcs_bucket"] )

    blob = bucket.blob( doc["target_gcs_prefix"] + "/" +  doc["scene_fn"] )
    blob.upload_from_filename("earth_moon/" + doc["scene_fn"] )

    blob = bucket.blob( doc["target_gcs_prefix"] + "/" +  doc["output_fn"] )
    blob.upload_from_filename(povray_cwd  +  doc["output_fn"] )



    os.remove( povray_cwd  +  doc["output_fn"]  )
    os.remove( "earth_moon/" + doc["scene_fn"] )

    logging.info("finished")

    return ( "povray_runner_doc: " , 204)











