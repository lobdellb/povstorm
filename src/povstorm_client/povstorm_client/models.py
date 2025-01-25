import pydantic
import pydantic_settings

# doc = {
#     "shared_gcs_content": ...,
#     "bespoke_gcs_content":...,
#     "inline_content": { "fn1": <base64encoded data>, "fn2": <base64encoded data> , ... }
#     "cmd": ...,
#     "local_result_fns": ["fn1","fn2",...],
#     "offload_gcs_path": ...
# }


class WorkUnit(pydantic.BaseModel):

    shared_resource_gcs_prefix: str = pydantic.Field(
        description="Location in GCS of the shared resources, which can include numerous files which are not flat in the OS.",
        pattern=r"^gs://[a-z0-9][a-z0-9_.-]{1,61}[a-z0-9](?:/[^\n\r]*)?$",
    )
    # bespoke_resource_gcs_prefix: str = pydantic.Field(description="Prefix in the GCS bucket of the bespoke resource, which is a single zip file.",pattern="^gs:\/\/([a-zA-Z0-9\-._]+)\/(.+)$")
    inline_resource: dict[str, str] = pydantic.Field(
        description="A dictionary of keys corresponding to local filenames with values containing the file content."
    )
    cmd: str = pydantic.Field(description="The POVRAY (or other) command to run.")
    # local_result_fns: List[str] = pydantic.Field(description="List of local filesnames which will be offloaded at the end of the render session.")
    offload_gcs_prefix: str = pydantic.Field(
        description="Location (ie,. URI + prefix where the list of files in local_result_fns will land.",
        pattern=r"^gs://[a-z0-9][a-z0-9_.-]{1,61}[a-z0-9](?:/[^\n\r]*)?$",
    )
    work_unit_id: str = pydantic.Field(
        description="A filesystem-compatible unique identifier for this workunit to differentiate it from other worknits.",
        pattern="^[a-zA-Z0-9_]*$",
    )
    job_id: str = pydantic.Field(
        description="A filesystem-compatible unique identifier for this job to differentiate it from other jobs.",
        pattern="^[a-zA-Z0-9_]*$",
    )


class Configuration(pydantic_settings.BaseSettings):

    MOUNT_PATH: str
