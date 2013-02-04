[![Code Climate](https://codeclimate.com/github/robertpyke/thesis.png)](https://codeclimate.com/github/robertpyke/thesis)

Thesis
======

A repository to hold code associated with my thesis

Preliminary Project Outline
------------------------------

This project will be developed in conjunction with the eResearch Virtual Labs project. The Virtual Labs project aims to allow researchers to interact with their data virtually, via an online lab.
The purpose of this thesis is to develop methods/strategies (e.g. clustering strategies) to permit users to interact with varying large geospatial datasets via an online mapping tool (like Google Maps), in a timely fashion. The outcome of this work will provide the foundation of the interactive geospatial component of the Virtual Labs project.

Project Goals
----------------

1. To create a modular software test framework to allow for the plug-and-play testing of various geospatial clustering methods, against varying interactive geospatial datasets.
2. To research and analyse existing clustering methods.
    - This research should look at pros/cons in regards to client/server processing, interaction time, database sizes, load time, etc.
3. Based on the research performed in step 2, create new, and or hybrid, clustering methods appropriate for the eResearch virtual labs project.

Project Details/Requirements
-------------------------------

1. The modular software test framework should allow for the uploading of large geospatial (lat/lng) datasets (100k+ data points) to the software test bench. These datasets should be stored at the remote server in a format that allows for the plug-and-play testing of various clustering strategies.
2. The software test framework should then allow for some degree of automated testing. This could include information on data fidelity across various zoom levels, server to client data transfer sizes, load times, etc.
3. All clustering strategies should allow for interaction with the datasets.
4. Software solution should be developed on open source software platforms, so as to comply with eResearch project requirements. e.g. OpenLayers instead of Google Maps.
