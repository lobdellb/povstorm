import math

import jinja2

import povstorm_client


def workunit_generator():

    # This example will render a sphere moving in a spiral.

    t = 0.0
    frame_rate = 30.0  # frames per second
    delta_t = 1 / frame_rate  # in seconds
    radial_velocity = 360.0  # in degrees per second
    z_velocity = 1.0  # POVRAY distance units per second
    t_end = 10.0  # in seconds
    # spiral_radius = 5.0       # in POVRAY distance units
    z_location = 0.0  # initial z location
    angle_degrees = 0.0  # in degrees

    while t < t_end:

        x_location = math.cos(2 * math.pi * angle_degrees / 360)
        y_location = math.sin(2 * math.pi * angle_degrees / 360)

        print(f"( x, y, z ) is ( {x_location}, {y_location}, {z_location} )")

        # create the bespoke resource(s)

        work_unit = povstorm_client.WorkUnit()

        yield work_unit

        z_location += delta_t * z_velocity
        angle_degrees += delta_t * radial_velocity
        t += delta_t


def generate_work_units():
    return


if __name__ == "__main__":

    cluster_obj = povstorm_client.Cluster(tf_outputs_fn="../tf_outputs.json")

    job_obj = povstorm_client.Job(cluster=cluster_obj)

    # kit for rendering the POV files
    MAIN_POVRAY_TEMPLATE_FILENAME = "sample.pov.jinja2"

    templateLoader = jinja2.FileSystemLoader(searchpath="./")
    templateEnv = jinja2.Environment(loader=templateLoader)

    main_povray_template = templateEnv.get_template(MAIN_POVRAY_TEMPLATE_FILENAME)
    scene_description_str = main_povray_template.render()

    job_obj = generate_work_units(workunit_emitter=workunit_generator)
