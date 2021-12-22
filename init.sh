#!/bin/bash

.shub/bin/shub-logo.sh

# Add deploy script to root
# ln -s .shub/bin/deploy.sh deploy.sh

# Remove Run info from README.md
# sed '/SHUBCONFIG/d' ./README.md > README.md

# Execute init script
./.shub/bin/init.sh
