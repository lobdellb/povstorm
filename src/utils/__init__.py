
import shlex
import hcl


def tfvars_to_env( fn: str ):

    with open( fn, "r" ) as fp:
        tfvars = hcl.load(fp)

    for k in tfvars:

        if isinstance( tfvars[k] , str ):
            print( f"TF_VAR_{k}={shlex.quote( tfvars[k] )}" )
