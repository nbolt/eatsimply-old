#!/bin/bash

fig run web cp config/database.yml.example config/database.yml.example
fig run web rake db:create
fig run web rake db:migrate
fig run web rake db:seed