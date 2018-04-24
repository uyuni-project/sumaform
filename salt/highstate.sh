#!/bin/bash

# Applies the highstate - assumes the minimal state was already applied

salt-call --local --file-root=/root/salt/ --log-level=info --retcode-passthrough --force-color state.highstate
