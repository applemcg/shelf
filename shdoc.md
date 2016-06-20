# Scope


This is the SHDOC *function family* User Guide. It supports the [SHELF
Standard](./shelf.org). See that standard for the role of a function
family.

The shdoc family supplies features to extract and display comments from
functions which define the interface to the function. The function
writer can supply information to describe the functions arguments, any
files that are read, any return values, and side-effects such as
changing the process state. or writing on files.

At this time (late June 2016), there is work in progress to build a
meta-language of nouns to collect useful data from the shdoc format. A
sneak peek at those words:

``` {.example}
    arguments  decision  effect   example  file       
    function   ref       returns  reads    writes
```

This work builds an information structure for functions suitable to
convert into a browser interface, capable of user/developer navigation
similar to the established scripting languages.

# History, Precendent


The functions here collect function descriptions. Precedent for the
practice was first established by
[Javadoc](https://en.wikipedia.org/wiki/Javadoc) and more recently in
[Perldoc](https://en.wikipedia.org/wiki/Plain_Old_Documentation) and
[Pydoc](https://en.wikipedia.org/wiki/Pydoc).

The shd *function family* is one member of the
[shelflib](./shreadme.org) library.

At the moment, the online references to shdoc refer to a
[shdoc package](http://mirror.unl.edu/ctan/macros/latex/contrib/shdoc/shdoc.pdf)
targeted at the TeX community, and not this 

These **shdoc** functions operate on shell functions similar to the
three mentioned above: Java, Perl, and Python. The two most useful
functions, **shdoc** and **shd_with** return a function body as the
collected comments in what I'm calling **shdoc**, or *shell doclib
comment* format.

# User Guide


There are two users of the **shdoc** function format, the function
writer or developer and the user, or ultimate customer of the
high-level, or user interface to the package supplied by the devloper.

## Developer

The developer needs to know how to create function comments capable of
final use by other developers and end-users. The developer's concern is
therefore about the syntax and production tools.

The top-level developer functions shown here

``` {.bash .rundoc-block rundoc-language="sh" rundoc-tangle="./inc/shdoc.0" rundoc-commentps="both" rundoc-padline="no"}
shdoc () 
{ 
    : this is a shell doclib "shdoc" comment;
    : an shdoc comment is the first ":"-origin lines;
    : in the shell function, the rest being the executable.;
    for f in ${*:-$(myname)};
    do
        shd_each $f;
    done
}
shd_with () 
{ 
    : removes shd_less functions from shdoc results;
    : creating function {name}_doc for function "name";
    shdoc $* | awk '
   #                  { print "DEBUG: ", fcount, last > "/dev/stderr"; }
   $1 ~ /function/   { fcount++; last = $0; next;  }
   $1 ~ /}/ && last  { next }
   last              { print last; last = ""; fcount = 0;  }
   fcount == 0       { print }
           '
}
shdoc_doc ()
{
    : this is a shell doclib "shdoc" comment;
    : an shddoc comment is the first ":"-origin lines;
    : in the shell function, the rest being the executable.;
}
```

Note the result. The **shdoc_doc** function is the first
colon-delimited lines of the **shdoc** function.

**shd_with** is the most useful of the bunch, as it says by removing
**shd_less** functions from shdoc results.

## shd_each

To complete the picture, here is **shd_each**. It's notable in that it
insists on being called by **shdoc**.

``` {.bash .rundoc-block rundoc-language="sh" rundoc-tangle="./inc/shdoc.1" rundoc-comments="both" rundoc-padline="no"}
shd_each () 
{ 
    report_notfunction $1 && return 1;
    report_notcalledby shdoc && return 2;
    trace_call $*;
    echo "function ${1}_doc {";
    declare -f $1 | awk '
       NR > 2 {
                if ( $1 !~ /^:/ ) exit
                else              print
          }
    ';
    echo "}"
}
```

Note **shd_each** produces the result for only one function, if only to
print a single function body; it insists on being called by **shdoc**.

Here's a question: *why doesn't shd_each have any shdoc comments?*

### other useful functions

Note the shell idiom in the **shd~top~** function. It's a convenient
shorthand to list a collection of similar names. In this case, this
*shdlib* conventionally defines functions whose name begins with
*shd\_*.

``` {.bash .rundoc-block rundoc-language="sh" rundoc-tangle="./inc/shdoc.2" rundoc-comments="both" rundoc-padline="no"}
shd_top () 
{ 
    echo shdoc shd_{oc,each,with,test,top}
}
shd_test () 
{ 
    : 1. test default, NO arguments, then;
    : 2. stub out test all functions in the library;
    : 3. demonstrate ignore subsequent comments;
    : 4. test shd_with;
    : 5. test shd_each defends against non-shdoc call;
    shdoc;
    :;
    set $(functions shdlib);
    : doit shdoc $*;
    shd_with $*;
    shd_each $*;
    declare -f shd_test | grep -v '^ *:' 1>&2
}
shd_init () 
{ 
    om_iam
}
shd_init 1>&2
```

The standard practice for such a library has a single executable as the
last line, as above.

The standard practice for a library family is now to call **om_iam**
from an *init* function for the family, in this case, **shd_init**

1.  it defines a help function, if not already defined, {arg}\_help,
    which lists the functions in the family
2.  it's first argument defines a function when called with an argument
    which is a member of the family, calls that function with the
    following arguments, otherwise, it calls the help function.

For example:

``` {.example}
$ shd top       # calls shd_top, returning
```

## Collect


Consider using the report\_ ... functions to collect the user guide

1.  arguments
    -   number, report~not~ ..
    -   files,
    -   names,

2.  files, report~notfile~ ...
    -   read
    -   written

3.  functions

# References

-   the [SHELF Standard](./shelf.org)
-   my [Commonplace Book](../book.org)

