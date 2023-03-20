import os
import contextlib


@contextlib.contextmanager
def cd(path):
    '''Creates the path if it doesn't exist'''
    old_dir = os.getcwd()
    try:
        os.makedirs(path)
    except OSError:
        pass
    os.chdir(path)
    try:
        yield
    finally:
        os.chdir(old_dir)


class SetDefault:
    '''Context manager like getattr, but yields a default value,
    and sets on the instance on exit:

    with SetDefault(obj, attrname, []) as attr:
        attr.append('something')
    print obj.something
    '''
    def __init__(self, obj, attr, default_val):
        self.obj = obj
        self.attr = attr
        self.default_val = default_val

    def __enter__(self):
        val = getattr(self.obj, self.attr, self.default_val)
        self.val = val
        return val

    def __exit__(self, exc_type, exc_value, traceback):
        setattr(self.obj, self.attr, self.val)


def set_default(obj, attr, default_val):
    with SetDefault(obj, attr, default_val) as result:
        return result


@contextlib.contextmanager
def index_error_stopiter():
    try:
        yield
    except IndexError:
        raise StopIteration()