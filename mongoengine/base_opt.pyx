import Document
from bson.dbref import DBRef

import cython
import operator

cdef extern from "Python.h":
    ctypedef struct PyTypeObject
    ctypedef struct PyObject
    int PyObject_TypeCheck(object, PyTypeObject*)
    int PyObject_HasAttrString(object, char*)

cdef inline bint typecheck(object ob, object tp):
    return PyObject_TypeCheck(ob, <PyTypeObject*>tp)

@cython.nonecheck(False)
def to_python(object cls, object value):
    cdef int v = typecheck(value, basestring)
    if v:
        return value

    if PyObject_HasAttrString(value, 'to_python'):
        return value.to_python()

    cdef int is_list = 0
    if PyObject_HasAttrString(value, 'items'):
        try:
            is_list = 1
            d = {}
            for k, v in enumerate(value):
                d[k] = v
            #value = dict([(k, v) for k, v in enumerate(value)])
        except TypeError:  # Not iterable return the value
            return value

    if cls.field:
        value_dict = {}
        c = cls.field.to_python
        for k, v in value.items():
            value_dict[k] = c(v)
        #value_dict = dict([(key, cls.field.to_python(item)) for key, item in value.items()])
    else:
        value_dict = {}
        for k, v in value.items():
            if isinstance(v, Document):
                # We need the id from the saved object to create the DBRef
                if v.pk is None:
                    cls.error('You can only reference documents once they'
                               ' have been saved to the database')
                collection = v._get_collection_name()
                value_dict[k] = DBRef(collection, v.pk)
            elif hasattr(v, 'to_python'):
                value_dict[k] = v.to_python()
            else:
                value_dict[k] = cls.to_python(v)

    if is_list:  # Convert back to a list
        return [v for k, v in sorted(value_dict.items(), key=operator.itemgetter(0))]
    return value_dict