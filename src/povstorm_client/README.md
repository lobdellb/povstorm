
# Organization

The idea is to make a tidy way to package all the resources needed to render a frame. Some resources are shared for the render job (ie., "shared resources"), this might include segments of the scene description (.pov) and image files. Other resources will be bespoke to a particular image (ie., locations of objects which will evolve over time/frame). The output needs to be collected and stored in GCS. The idea is to package things in a way which allows flexible design of the scene descriptions source (.pov file).  The `povstorm_client` should make it easy to construct these WorkUnits and run a job.


# Objects

* Cluster - Names and IDs of terraform-managed resources and methods needed to deal with them.
* Job - A collection of workunits
* WorkUnit - A dataclass which contains
    * shared_resource_gcs_prefix: str - Tells the renderer where the shared resources are in GCS, and this path will be softlinked in the workspace path as ./shared.
    * inline_resource: dict - A files bespoke to this WorkUnit. The key of the path of the sources in the workspace path. The value is the base64 encoded binary data.
    * offload_gcs_prefix: str - This is where the output files are stored in GCS. This path is softlinked to ./output in the workspace path.
    * cmd - This is the command which runs POVRAY. Populated by the WorkUnit not by the client program.
    * work_unit_id - Generated.
    * job_id - Generated.


# Client workflow

* Configure an instance of a `Cluster` object, configured with the TF outputs file.
* Create a `Job` object and pass it the instance of `Cluster` object.
    * Add shared resources to the `Job` object which will appear in `./shared/` from the perspective of the 
* Construct a `for` loop
    * Create a new `WorkUnit`
        * Add all inline resources.
* Run the job
    * The client will poll for completion.
* Use the job object to recover the images, video, and job statistics. 




# Work diary

* Jan 19 - Working on setting up an example job which I can use to test the full workflow.
    * Drafting the example job
    * Editing the client and job to make sure they match.
    * Writing tests for the client.