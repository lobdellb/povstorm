# This module is meant to dovetail with the terraform module.
#
# - The terraform module stands up a few pieces of infrastructure which make it easy to parallelize
#   the rendering work.
# - This client makes it easy to run "jobs" from a local python client. Running a "job" with this
#   client will cause the host machine to make a bunch of API calls to GCP services (mostly PubSub)
#   and then poll for status.


# Concepts which will need an class
#
# - Job - Uses a Cluster to do WorkUnits.
# - Cluster - Configuration for the GCP resources needed to do WorkUnits, also some observability.
#   - Storage <--- Maybe unnecessary, not yet implemented
# - WorkUnit - The set of artif <--- maybe unecessary, not yet implemented
#   - Package - All the stuff which a worker needs to compute a result.
#       - SharedResource
#       - BespokeResource
# -


# Expected workflow looks like this

# cluster_obj = Cluster( gcp_project, namespace )

# job_obj = Job( shared_package, bespoke_generator )

# cluster_obj.run( job_obj, waitfor=True )

# import datetime
import json
import logging

# import os
# import time
import typing

from google.cloud import storage

# import povstorm_client.models
from . import models

logger = logging.getLogger()


def get_tf_outputs(tf_outputs_fn: str):

    with open(tf_outputs_fn, "r") as fp:
        for this_json in fp:  # each this_json is a line, the last line is the outputs
            tf_outputs = json.loads(this_json)

    return tf_outputs


class Cluster:

    def __init__(self, tf_outputs_fn: str):

        self.tf_outputs = get_tf_outputs(tf_outputs_fn)

        self.inbound_topic_id = self.tf_outputs["outputs"]["inbound_topic_id"]
        self.gcp_project = self.tf_outputs["outputs"]["target_gcp_project_id"]
        self.work_bucket_name = self.tf_outputs["outputs"]["work_bucket_name"]
        self.povstorm_namespace = self.tf_outputs["outputs"]["povstorm_namespace"]

    # def run(self, job_obj: Job ):

    #     # generate a run ID and run metadata
    #     start_dt = datetime.datetime.now()
    #     run_id = str(int(time.time()))

    #     # upload the shared resources
    #     job_obj.shared_resource.upload()


class Job:
    """Job class"""

    # Some comments on the design
    # - I don't want this class to do any actual work until the execute() method has been called.

    def __init__(self, cluster: Cluster):

        # need to get
        # - the bucket name
        # - the shared resource prefix

        self.cluster = cluster
        self.shared_resources = []
        self.workunits = []
        self.gcs_client = storage.Client()
        self.work_bucket_name = cluster.work_bucket_name
        self.shared_resources = []

    def add_shared_resource_from_bytes(self, remote_path: str, content_bytes: bytes):
        self.shared_resources.append(
            {"remote_path": remote_path, "content_bytes": content_bytes}
        )

    def add_shared_resource_from_string(self, remote_path: str, content_str: str):
        # return self.add_shared_resource_from_binarray( remote_path=remote_path, content_bytes=content_str.encode("utf-8")  )
        self.shared_resources.append(
            {"remote_path": remote_path, "content_str": content_str}
        )

    def add_shared_resource_from_file(self, remote_filename: str, local_filename: str):
        self.shared_resources.append(
            {"remote_path": remote_filename, "local_filename": local_filename}
        )

    def _upload_shared_resources(self):

        local_filename = None
        remote_filename = None

        bucket = self.gcs_client.bucket(self.work_bucket_name)

        for shared_resource in self.shared_resources:
            blob = bucket.blob(remote_filename)

            if "local_filename" in shared_resource:
                blob.upload_from_filename(local_filename)
            elif "content_str" in shared_resource:
                blob.upload_from_string(shared_resource["content_str"])
            elif "content_bytes" in shared_resource:
                blob.upload_from_string(shared_resource["content_str"])
            else:
                raise Exception(
                    "Job:_upload_shared_resources: found an unknown shared_resource type, probalby due to a bug."
                )

    def _upload_workunit(self, workunit: models.WorkUnit):
        pass

    def generate_work_units(self, workunit_emitter: typing.Callable):

        workunit = None

        for item in workunit_emitter():
            self._upload_workunit(workunit)

    def execute(self):

        self._upload_shared_resources()


class WorkUnit(models.WorkUnit):

    # shared_resource_gcs_prefix: str = pydantic.Field(description="Location in GCS of the shared resources, which can include numerous files which are not flat in the OS.",regex="^gs:\/\/([a-zA-Z0-9\-._]+)\/(.+)$")
    # inline_resource: Dict[str,str] = pydantic.Field(description="A dictionary of keys corresponding to local filenames with values containing the file content.")
    # cmd: str = pydantic.Field(description="The POVRAY (or other) command to run.")
    # offload_gcs_prefix: str = pydantic.Field(description="Location (ie,. URI + prefix where the list of files in local_result_fns will land.",regex="^gs:\/\/([a-zA-Z0-9\-._]+)\/(.+)$")
    # work_unit_id: str = pydantic.Field(description="A filesystem-compatible unique identifier for this workunit to differentiate it from other worknits.",regex="^[a-zA-Z0-9_]*$")
    # job_id: str = pydantic.Field(description="A filesystem-compatible unique identifier for this job to differentiate it from other jobs.",regex="^[a-zA-Z0-9_]*$")

    def __init__(self):

        # Stuff we need to onboard:
        # - All inline resources
        # -

        # Todo on creation:
        # - initialize the object, but not validate
        # - generate the workunit_id

        # Need to do before the workunit can be executed
        # - populate cmd
        # - populate the hared_sources_gcs_prefix
        # - populate the offload_gcs_prefix
        # - populate the job_id

        self.model_construct()  # this should build the model but not fail validation
        # super().__init__()


# class Storage():

#     def __init__(self, gcp_project, namespace ):
#         self.gcp_project = gcp_project
#         self.namespace = namespace


# class SharedResource():

#     def __init__(self, local_path: str ):
#         self.local_path = local_path

#     def upload( gcs_bucket:str, gcs_prefix:str ):

#         gcs_client = storage.Client()

#         bucket_obj = storage.get_bucket( gcs_bucket )

#         local_path += "/" if local_path[-1] != "/" else ""
#         gcs_prefix += "/" if gcp_prefix[-1] != "/" else ""

#         for f in glob.glob( self.local_path + "**", recursive=True ):

#             postfix = f.replace( self.local_path, "" )

#             blob_obj = bucket_obj.blob( gcs_prefix + postfix )
#             blob_obj.upload_from_file( f )


# class BespokeResource():

#     def __init__(self, generator ):

#         self.generator = generator
#         self.count = 0

#     def wrapped_generator(self):

#         for d in self.generator:
#             yield d
#             self.count += 1

#     def get_generator(self):
#         return self.wrapped_generator
