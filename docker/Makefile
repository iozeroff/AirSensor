################################################################################
# Makefile for building and running docker containers

# PRODUCTION version -----------------------------------------------------------

AirSensor_tarball:
	cd ..; R CMD build --resave-data .
	mv ../AirSensor_0.7.2.tar.gz .

production_build:
	docker build --no-cache -t mazamascience/airsensor:0.7.2 -t mazamascience/airsensor:latest .
