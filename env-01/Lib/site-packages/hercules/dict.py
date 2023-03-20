import functools

from hercules.loop_interface import IteratorWrapperBase


class KeyClobberError(KeyError):
    pass


class NoClobberDict(dict):
    '''An otherwise ordinary dict that complains if you
    try to overwrite any existing keys.
    '''
    KeyClobberError = KeyClobberError
    def __setitem__(self, key, val):
        if key in self:
            msg = "Can't overwrite key %r in %r"
            raise KeyClobberError(msg % (key, self))
        else:
            dict.__setitem__(self, key, val)

    def update(self, otherdict=None, **kwargs):
        if otherdict is not None:
            dupes = set(otherdict) & set(self)
            for dupe in dupes:
                if self[dupe] != otherdict[dupe]:
                    msg = "Can't overwrite keys %r in %r"
                    raise KeyClobberError(msg % (dupes, self))
        if kwargs:
            for dupe in dupes:
                if self[dupe] != otherdict[dupe]:
                    msg = "Can't overwrite keys %r in %r"
                    raise KeyClobberError(msg % (dupes, self))
        dict.update(self, otherdict or {}, **kwargs)



# -----------------------------------------------------------------------------
# Dict filter class.
# -----------------------------------------------------------------------------
class NonExistentHandler(object):
    '''Raise if someone tries a dunder query that isn't supported.
    '''


class DictFilterMixin(object):
    '''
    listy = [dict(a=1), dict(a=2), dict(a=3)]
    for dicty in DictFilter(listy).filter(a=1):
        print dicty

    '''
    def filter(self, **kwargs):
        '''Assumes all the dict's items are hashable.
        '''
        # So we don't return anything more than once.
        yielded = set()

        dunder = '__'
        filter_items = set()
        for k, v in kwargs.items():
            if dunder in k:
                k, op = k.split(dunder)
                try:
                    handler = getattr(self, 'handle__%s' % op)
                except AttributeError:
                    msg = '%s has no %r method to handle operator %r.'
                    raise NonExistentHandler(msg % (self, handler, op))
                for dicty in self:
                    if handler(k, v, dicty):
                        dicty_id = id(dicty)
                        if dicty_id not in yielded:
                            yield dicty
                            yielded.add(dicty_id)
            else:
                filter_items.add((k, v))

        for dicty in self:
            dicty_items = set(dicty.items())
            if filter_items.issubset(dicty_items):
                yield dicty

    def handle__in(self, key, value, dicty):
        dicty_val = dicty[key]
        return dicty_val in value

    def handle__ne(self, key, value, dicty):
        dicty_val = dicty[key]
        return dicty_val != value


class IteratorDictFilter(IteratorWrapperBase, DictFilterMixin):
    '''A dict filter that wraps an iterator.
    '''
    pass


def iterdict_filter(f):
    @functools.wraps(f)
    def wrapped(*args, **kwargs):
        result = f(*args, **kwargs)
        return IteratorDictFilter(result)
    return wrapped



class DictSetDefault:
    '''Context manager like getattr, but yields a default value,
    and sets on the instance on exit:

    with DictSetDefault(somedict, key, []) as attr:
        attr.append('something')
    print obj['something']
    '''
    def __init__(self, obj, key, default_val):
        self.obj = obj
        self.key = key
        self.default_val = default_val

    def __enter__(self):
        val = self.obj.get(self.key, self.default_val)
        self.val = val
        return val

    def __exit__(self, exc_type, exc_value, traceback):
        self.obj[self.key] = self.val


class DictSetTemporary:
    def __init__(self, dicty):
        self.dicty = dicty
        self.backup = {}
        self.remove = set()

    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc_value, traceback):
        '''Restore the mutated items to the previous state.
        '''
        dicty = self.dicty
        for key, value in self.backup.items():
            dicty[key] = value
        for key in self.remove:
            dicty.pop(key)

    def __setitem__(self, key, value):
        if key in self.dicty:
            self.backup[key] = self.dicty.pop(key)
        else:
            self.remove.add(key)
        self.dicty[key] = value

    def __getitem__(self, key):
        return self.dicty[key]

    def __delitem__(self, key):
        self.backup[key] = self.dicty.pop(key)

    def update(self, dicty=None, **kwargs):
        for dicty in (dicty or {}, kwargs):
            for key, value in dicty.items():
                if key in self.dicty:
                    self.backup[key] = self.dicty.pop(key)
                else:
                    self.remove.add(key)
                self.dicty[key] = value

    def get(self, key, default=None):
        return self.dicty.get(key, default)

