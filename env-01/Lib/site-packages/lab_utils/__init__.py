# -*- coding: utf-8 -*-
# Author: Carlos Vigo
# Contact: carlosv@phys.ethz.ch

""" Collection of useful modules to build consistent Python apps.
All modules share some basic principles to increase app compatibility
and facilitate development:

-   **Settings**. The modules have a :meth:`config` method based in
    the standard library :obj:`configparser`. Documentation about the
    different configuration files can be found in the
    :ref:`examples section<configuration-files>`.

-   **Logging**. The modules use the standard :obj:`logging` library
    to manage logs at all
    `levels <https://docs.python.org/3/library/logging.html#logging-levels>`_.
    Each method will produce logs using a logger named like the method itself,
    so an app importing the module can easily modify the logging behaviour
    on a per-method basis. This is shown in the example
    TODO.
"""

# Local imports
from . import database, socket_comm, custom_logging, __project__

__all__ = [
    __project__.__author__,
    __project__.__copyright__,
    __project__.__short_version__,
    __project__.__version__,
    __project__.__project_name__,
    'database',
    'socket_comm',
    'custom_logging',
]
