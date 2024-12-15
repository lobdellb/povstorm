
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

import os
import time
import datetime
import logging

from google.cloud import storage

logger = logging.get_logger()


class Cluster():

    def __init__(self, gcp_project: str, namespace: str ):
        self.gcp_project = gcp_project
        self.namespace = namespace

    def run(self, job_obj: Job ):

        # generate a run ID and run metadata
        start_dt = datetime.datetime.now()
        run_id = str(int(time.time()))

        # upload the shared resources
        job_obj.shared_resource.upload()


        for w in 



# class Storage():

#     def __init__(self, gcp_project, namespace ):
#         self.gcp_project = gcp_project
#         self.namespace = namespace


class Job():

    def __init__(self, shared_resource: SharedResource, bespoke_resource: BespokeResource ):

        self.shared_resource = shared_resource
        self.bespoke_resource = bespoke_resource






class SharedResource():

    def __init__(self, local_path: str ):
        self.local_path = local_path

    def upload( gcs_bucket:str, gcs_prefix:str ):

        gcs_client = storage.Client()

        bucket_obj = storage.get_bucket( gcs_bucket )

        local_path += "/" if local_path[-1] != "/" else ""
        gcs_prefix += "/" if gcp_prefix[-1] != "/" else ""

        for f in glob.glob( self.local_path + "**", recursive=True ):

            postfix = f.replace( self.local_path, "" )

            blob_obj = bucket_obj.blob( gcs_prefix + postfix )
            blob_obj.upload_from_file( f )





class BespokeResource():

    def __init__(self, generator ):

        self.generator = generator
        self.count = 0

    def wrapped_generator(self):

        for d in self.generator:
            yield d
            self.count += 1

    def get_generator(self):
        return self.wrapped_generator



@dataclass
class WorkUnit():

    pov_file: str 
