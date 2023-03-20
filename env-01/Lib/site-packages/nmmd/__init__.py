# -*- coding: utf-8 -*-
"""Non-Magical Multiple Dispatch"""
# :copyright: (c) 2009 - 2012 Thom Neale and individual contributors,
#                 All rights reserved.
# :license:   BSD (3 Clause), see LICENSE for more details.


from nmmd.base import Dispatcher, DispatchError, TypeDispatcher
from nmmd.ext.regex import RegexDispatcher


__all__ = ['Dispatcher', 'DispatchError']
