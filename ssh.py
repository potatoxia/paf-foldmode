#!/usr/bin/env python

import os

dname = "foldmode"

os.system("docker exec -it {:s} /bin/bash".format(dname))
