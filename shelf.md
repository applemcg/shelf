# Scope

This document is a *draft* for a Shell Library-Function Standard, a
SHELF, for easy recall. As such it sets a practice for organizing shell
functions into re-usable libraries. It introduces standards for a
library, and for functions in the library. A library may contain one or
more *families*, the organizing principal for functions.

A section of the standard suggests steps for verifying conformance.

In an attempt to keep the standard concise, here is the [SHELF Rationale
and Practice](./shreadme.md).

## What's it about

The standard offers:

-   conventions for organizing, collecting and re-using shell functions
-   naming libraries and functions according to collections
-   coding conventions within a function

It offers strong suggestions pointing to specific function libraries
supporting a number of areas in the library-function practice. The
ubiquity of the
[bash shell](https://en.wikipedia.org/wiki/Bash_%28Unix_shell%29)
makes it the implementation choice.

At the moment, these function families are featured as supporting the
standard:

-   **om** -- the object-model, or object-method for naming functions
-   **report** -- or **assert** for verifying function arguments
-   **shdoc** -- a subset, the Shell DOCumentation standard, after
    JavaDoc, etc.
-   **trace** -- function execution tracing, and
-   **util** -- a few programming functions, .e.g. *foreach*

## Why the standard 

The purpose of the SHELF standard is to make re-usable components.
To that end the features of the function families enable:

- standardized function assertion-checking
- incorporating developer/user documentation features to foster re-use
- a direction for debugging, performance testing, e.g.  tracing.
- a direction for organizing functions in "families" and libraries

## What it's not about

The shell library-function standard has nothing to say about:

-   shell scripts, and the 
    [sh-bang](https://en.wikipedia.org/wiki/Shebang_%28Unix%29) feature
-   [cron jobs](https://en.wikipedia.org/wiki/Cron), stand-alone
    operation

The practice from which the standard has been derived suggests
composing a script is an added after-thought of the design process.
With standard libraries, an application may first appear as a
function. These may then be turned in to a stand-alone application,
cron-job or script.

## About requirements

Since this is a draft standard, requirements are not put forward in
'requirement-speak'. It should be clear from the tense of the verbs how
strong a requirement is. The purpose of the requirements and
recommendations should become clear on reading.

The requirements are organized first for Libraries, then Families, and
then for the Functions in a library.

# Libraries

A library:

1.  is named *something*lib, without a suffix. e.g. `setpathlib`
1.  is *source*d by the shell. e.g.

    ``` {.example}
    source setpathlib  # or
    . setpathlib
    ```

    with the strong implication it is found on the **PATH**
1.  when *source*d leaves nothing on **stdout**
1.  is not an application. It may have multiple functions used
    principally from the command line.
1.  must have an *init* function, conventionally named for
    its basename. e.g. setpathlib has a function *setpath_init*
1.  must have no more than one directly executable statement, calling
    the initialization function, which certainly causes other execution.

    ``` {.example}
    setpath_init 1>&2
    ```

    Here, the re-direction is to comply with the earlier requirement.
1.  may have multiple *families* in the library, each of which may have
    its own *init* function

# Families

A *family* is a group of functions sharing a common first component,
before the first underscore in a name:

``` {.example}
family_subfunction
```

is the name of a function in the named *family*.

This standard specifies certain required behavior for sub-functions:

-   help -- may write any useful instructions on **stdout**
-   init -- mandatory behavior calls **om_iam** to identify the family,
    and any other necessary features when the family library is
    `sourced`
-   list -- returns a list of the family function names.

# Functions

A function included in a SHELF library:

1.  has two or more characters in an alpha-numeric name, which matches
    the regular expression:

    ``` {.example}
    [a-zA-Z][a-zA-Z0-9_]+
    ```

2.  has a preference for a *family* group, e.g. {family}~subfunction~
    such as *setpath_init*. (see the [om, object and
    methods](shelflib.md::*om,%20object%20and%20methods) family
    of functions)
3.  is formatted in the canonical format:

    ``` {.example}
    declare -f fun_method
    ```

    since ordinary shell "\#" comments are lost to this format, an
    alternate comment format is available (see the
    [shdoc](shelflib.md::*shdoc) function).
4.  should test any assertions capable of begin made on its arguments
    (see the [reporting](shelflib.md::*reporting) functions). At the
    current moment, there are these two alternatives:

    ``` {.example}
    assert_isfile $1 || return 1     # is the first arg a file?, OR
    report_notfile $1 && return 1    # the current practice
    ```

5.  is encouraged to make liberal use of positional parameters, and the
    **set** facility. e.g. where a conventional use of file suffixes is
    at the heart of the process, rather than this:

    ``` {.example}
    call_me  file.txt. file.out file.err
    ```

    use this instead:

    ``` {.example}
    call_me file       # or
    call_me file.txt   # and therefore be defined as:
    ...
    call_me () {
       set ${1%.*}               # strip any suffix, or not!
       set $1.txt $1.out $1.err  # $1, $2, and $3 are as before.
    ...
    ```

6.  should trace its entry:
    -   after positional parameters are set, and
    -   after assertion checking is complete.

    which may occur interchangeably. For example, a reliable first
    assertion is on the number of arguments:

    ``` {.example}
    report_notargcount 1 $# No file or basename && return 1
    ```

    might be used as the first assertion in a function.
7.  should limit control structures to one level. (see **foreach** in
    the collection of utilities).

# Verification

A set of not-too-automated functions and procedures may be supplied here
used to verify a library's conformance to this standard.

## test points

## demonstrating failure

Since *a good test is one which has a high probability of detecting an
otherwise undetected error. A successful test is one which does*. --
[Glenford Myers, The Art of Software
Testing](https://en.wikipedia.org/wiki/Glenford_Myers)

# References

-   the [SHELF Rationale and Practice](./shreadme.md).

Search for:

-   [shdoc](http://www.ctan.org/pkg/shdoc)
-   [Javadoc](https://en.wikipedia.org/wiki/Javadoc)
-   [Perldoc](http://perldoc.perl.org)
-   [Pydoc](http://pydoc.org)

