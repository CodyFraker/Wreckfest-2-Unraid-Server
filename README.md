# wreckfest2-docker-server

NOTE: This is a very early version of this project. There are no guarantees that it will work as expected, though the actual server should be stable enough for normal use.

Optionally, you can enable the experimental console, which is a work in progress. It allows you to have console input and output directly to the Wreckfest 2 server. There may be some bugs, but they should be limited to output rather than input.

## Running the image:

docker run -d -p 30100:30100/udp nvitaterna/wreckfest2-docker-server

Running the image with the experimental console:

docker run -p 30100:30100/udp -e EXPERIMENTAL_CONSOLE=1 nvitaterna/wreckfest2-docker-server
