#!/bin/bash

echo "Deploy santoku to /usr/local/bin"
sudo cp -prv santoku /usr/local/bin
sudo chmod a+rx /usr/local/bin/santoku
