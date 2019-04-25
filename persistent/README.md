this folder mounted to each component and contains configuration and artifact deploy instructions.

the file `env.properties` is an entry-point configuration file that defines all configuration folders to be loaded and deployment/templates folders to be copied into the docker on docker startup.

this works for images built on top of https://hub.docker.com/r/eleks/base-ubuntu-jdk8-groovy image.

the details about this image you can find in the following repository: https://github.com/eleks/wso2-dockers/tree/master/base-jdk8-groovy