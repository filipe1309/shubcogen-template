#!/bin/bash

.shub/shub-logo.sh

# Remove Run info from README.md
sed '/SHUBCONFIG/d' ./README.md > README.md

# Execute init script
./.shub/init.sh
