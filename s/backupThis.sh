#!/usr/bin/bash
tar --exclude .git -c $1 -f /tmp/config.tar
