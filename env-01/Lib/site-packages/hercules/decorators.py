import pickle
import functools


class CachedAttr(object):
    '''Computes attr value and caches it in the instance.'''

    def __init__(self, method, name=None):
        self.method = method
        self.name = name or method.__name__

    def __get__(self, inst, cls):
        if inst is None:
            return self
        result = self.method(inst)
        setattr(inst, self.name, result)
        return result


class CachedClassAttr(object):
    '''Computes attribute value and caches it in class.

    Example:
        class MyClass(object):
            def myMethod(cls):
                # ...
            myMethod = CachedClassAttribute(myMethod)
    Use "del MyClass.myMethod" to clear cache.'''

    def __init__(self, method, name=None):
        self.method = method
        self.name = name or method.__name__

    def __get__(self, inst, cls):
        result = self.method(cls)
        setattr(cls, self.name, result)
        return result


def memoize_methodcalls(func, pickle=False, dumps=pickle.dumps):
    '''Cache the results of the function for each input it gets called with.
    '''
    cache = func._memoize_cache = {}
    @functools.wraps(func)
    def memoizer(self, *args, **kwargs):
        if pickle:
            key = dumps((args, kwargs))
        else:
            key = args
        if key not in cache:
            cache[key] = func(self, *args, **kwargs)
        return cache[key]
    return memoizer
