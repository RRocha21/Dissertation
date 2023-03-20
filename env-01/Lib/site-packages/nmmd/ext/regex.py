import re

from nmmd.base import Dispatcher, try_delegation


class RegexDispatcher(Dispatcher):

    @try_delegation
    def prepare(self):
        data = []
        for invoc, method in self.registry:
            args, kwargs = self.loads(invoc)
            rgx = re.compile(*args, **kwargs)
            data.append((rgx, method))
        return data

    @try_delegation
    def get_text(self, text):
        return text

    @try_delegation
    def gen_methods(self, *args, **kwargs):
        text = self.get_text(*args, **kwargs)
        for rgx, methodname in self.dispatch_data:
            matchobj = rgx.match(text)
            if matchobj:
                method = getattr(self.inst, methodname)
                # args = (text, matchobj) + args
                # yield method, args
                # args = (text, matchobj) + args
                yield method, (text, matchobj)

        # Else try inst.generic_handler
        generic = getattr(self.inst, 'generic_handler', None)
        if generic is not None:
            yield generic

    @try_delegation
    def apply_handler(self, method_data, *args, **kwargs):
        '''Call the dispatched function, optionally with other data
        stored/created during .register and .prepare. Assume the arguments
        passed in by the dispathcer are the only ones required.
        '''
        if isinstance(method_data, tuple):
            len_method = len(method_data)
            method = method_data[0]
            if 1 < len_method:
                args = method_data[1]
            if 2 < len_method:
                kwargs = method_data[2]
        else:
            method = method_data
        return method(*args, **kwargs)
