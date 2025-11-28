#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
sudo apt remove --purge -y linux-image-$(uname -r)
