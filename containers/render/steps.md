
# Steps to make this go


## On the container side
	* Function to run the povray CLI
	* Download the GCS file to local fs
	* Script to upload the container and install it
	* Script to create the pubsub + subscription
	* Identity for the container


## On the python/local side

* Make a thing which packages most of the contents and the main file into a tar file and upload to a bucket.
	* DONE Make a bucket ( brycelobdell-terraform-play2-povray )
	* Piece of python in the notebook which packages the stuff to a .tar file
* Make a thing which sends messages to pubsub, the package contains
	* The name of the GCS file/package
	* The contents of the .inc file which is packaged with it to be run
	* the CLI for povray to run