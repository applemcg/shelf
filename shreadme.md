``` {.example}
SHELF Rationale and Practice
```

Scope
=====

This document supports the [SHELF Standard](./shelf.org). In addition to
providing rationale for the standard, it documents the function families
which support an implementation of the standard.

**IT is TAKING over the job from [AUXLIB](./auxlib.org)**. All families
are as before, except unique `auxlib` functions (no other family) are
now in the **util** group (a collection without a family). This
paragraph will disappear when the turn-over is complete.

The **SHELF** sets a practice for organizing shell functions into
re-usable libraries. As a library, the `shelflib` contains the
standard-supporting function families. The library's source is embedded
in this document as [tangled fragments](./tangle.org). The ancillary
`tanglelib` which is not part of the SHELF manages the production and
installation of the `shelflib`

Families
========

Here are the five function families which support the SHELF standard.
Their code is shown below, collected by family; The user guides for the
function families are now separate documents.

om -- the object-model, or object-method for naming functions
-------------------------------------------------------------

report -- or **assert** for verifying function arguments
--------------------------------------------------------

A reporting function may be used in any shell function which needs to
assert its arguments as to number, type of file, or string length, and
any assertion you can support with a function.

This is a typical use of one of these functions as an assertion:

``` {.example}
report_not{something} $1 && return N
```

where N is usually a 1, ... the number of an error return from the user
function, and "something" is *readable, writable, executable*, ....

Here is a sample function.

``` {.example}
function report_notreadable
{ 
    [[ -r $1 ]] && return 1;
    report_usage $1 is NOT readable
}
```

Notice the usage above. It's a positive statement to assert an argument
isn't something, and return a failure when that's the case. So, the user
function lines up as many assertions on it's arguments as needed. The
first one to fail produces the required message and returns from the
function with a message on *stderr* from **report~usage~**. Otherwise
the function executes as desired.

shdoc -- the SHell DOCumentation standard
-----------------------------------------

These functions encourage a programmer to write a brief introductory
user guide to each function. Here is the [shdoc family user
guide](./shdoc.org).

The family name is the **shd** prefix. The functions in this family set
a standard for shell doclib capture and presentation. Precedent for the
practice was first established by
[Javadoc](https://en.wikipedia.org/wiki/Javadoc) and more recently in
[Perldoc](https://en.wikipedia.org/wiki/Plain_Old_Documentation) and
[Pydoc](https://en.wikipedia.org/wiki/Pydoc).

A majority of online references to "shdoc" are few and disjoint. The
most common reference to an [shdoc
package](http://mirror.unl.edu/ctan/macros/latex/contrib/shdoc/shdoc.pdf)
is a tool kit for caputuring command line usage and is built for the TeX
community.

trace -- function execution tracing, and
----------------------------------------

The tracing feature of these shell functions uses *(trace\_call)* in a
function body after some assertion validation using the **report**
functions. While it's not dependent on all assertions passing, it seems
useful to dispose of the assertions, which announce a failure, and then
announce the function body is ready to work.

Tracing my be enabled or disabled, by *(trace\_on)* or *(trace\_off)*.
Either of them reset the function behavior to either *(trace\_stderr)*,
or simply **return**, respectively.

At bottom, the tracing logs it's calls to a per-user file:

``` {.example}
HOME/lib/trace.log
```

and echo's each call to the **stderr**, which may be separately saved or
altogether ignored:

``` {.example}
... 2> trace.err    # say, or
... 2> /dev/null    # the "bit-bucket"
```

In any case, while tracing is enabled, the *(logDateOnceHourly)*
function inspects the latest entry in the log to see if it's time to
post a new HOUR mark. I felt it useful to collect usage at this level,
anticipating collecting function usage statistics. On reflection, the
necessary test for the last record might be more work than necessary.
I've done some work elsewhere, to collect the hourly work by number of
command executions.

For each call, the trace log collects two function names: the current
function and it's calling function. This enables a user to construct a
calling tree from the log.

util -- a few programming functions, .e.g. *foreach*
----------------------------------------------------

Functions
=========

By family, where the utilies aren't a family, but the missing pieces.
Nothing in the library uses a function not in the library.

om family
---------

### om~iam~

The **om~iam~** function is the main user function. It must be called by
the family's *~init~* function. When called, it creates these functions,
where subfunctions are appended to the family name. e.g. *family~list~*:

1.  *family* -- uses **om~generic~** to supply help and firsttime
    functionality
2.  *~firsttime~* -- executed the first time the family is loaded, whose
    default action is to supply the copyright notice for the family.
3.  *~list~* -- if not already defined, produces the list of family
    member functions
4.  *~vars~* -- if not already defined, produces the names of family
    member shell variables
5.  *~help~* -- if not already defined, produces a help message,
    defaluting to the family list and family variables

### om~generic~

This function offers it's users three standard features:

1.  any function in such a family may be invoked:

    ``` {.example}
    family subfun arg ...     # rather than
    family_subfun arg ...     
    ```

    the simple reason being for command line use; the apace bar is much
    more convenient than the underscore. having supplied this gloss,
    it's necessary to point out to use the underscore name when using
    such a function in other functions, simply for name-discovery.
2.  the default behavior for the head of the *family*, the family-name
    itself, is identical to the the use:

    ``` {.example}
    family help
    ```

3.  invokes the function:

    ``` {.example}
    family firsttime
    ```

    only the first time the *family* or one of it's members is called
    thru the family name. This is a way to display a copyright notice
    only once, the default behavior. In this sence, the first time means
    "in the process of the current shell".

``` {.bash .rundoc-block rundoc-language="sh" rundoc-tangle="./inc/om.0" rundoc-comments="both" rundoc-padline="no"}
copyright_om () 
{ 
    comment "Copyright (C) 2014-2016, JYATL - Just Yet Another Testing Lab";
    comment "mailto: mcgowan (at) alum DOT mit DOT edu";
}
om_tally () 
{ 
    trace_call $*;
    om_list | sort | uniq -c
}
om_help () { echo to see OM functions, om_list; }
om_list () 
{ 
    sfg _ | awk -F_ '{ printf "object\t%s\nmethod\t%s\n", $1, $2 }'
}
om_init () 
{ 
    declare -f om_iam >/dev/null || { comment $(myname) OM_IAM is NOT a function; return 1; }
    om_iam
}
om_iam () 
{ 
    : user identifies themself as an OM object;
    set $(myname 2);
    set ${1%_init};
    report_notcalledby ${1}_init && return 1;

    : create the OM function
    eval "$1 () { om_generic $1 \$*; }"

    : every family has a list of members
    local l=${1}_list;
    declare -f $l > /dev/null 2>&1 || {
         eval "$l () { (sfg ^${1}_; sfg _${1}$) 2>/dev/null; }";
    }
    : every family may have shell varialbles
    local v=${1}_vars;
    local V=$(UC $1)
    declare -f $v > /dev/null 2>&1 || {
         eval "$v () { set | grep ^${V}_ 2>/dev/null; }";
    }
    : and a default help function when one doesnt exist
    local h=${1}_help;
    declare -f $h > /dev/null 2>&1 || {
         eval "$h () { echo $1 functions, variables:; ($v; $l) | sed 's/^/  /'; }";
    }
    : shows Copyright when library is sourced.
    local f=${1}_firsttime;
    eval "$f () { copyright_${1}; unset $f; }";

    : and displays the help
    ${1}_help 
}
om_generic () 
{ 
    : ~ fun { sub arg ... };
    : prefereably executes FUN_SUB arg ...;
    : or FUN_HELP;
    : ====================================;
    local fun=$1;
    shift;
    : only when a function is first use thru the model;
    declare -f ${fun}_firsttime > /dev/null && ${fun}_firsttime;
    [[ $# -lt 1 ]] && { 
        ${fun}_help 2> /dev/null;
        return
    };
    local f=${fun}_$1;
    shift;
    declare -f $f >/dev/null 2>&1 || { 
        ${fun}_help 2> /dev/null;
        return
    };
    $f $*
}

```

report family
-------------

### reportlib, main

And here is the `report` function family.

First a copyright, then the initialization function. Since this is a
*family*, the only necessary call is to **om~iam~**

``` {.bash .rundoc-block rundoc-language="sh" rundoc-tangle="./inc/report.0" rundoc-comments="link" rundoc-padline="no"}
copyright_report () 
{ 
    comment "Copyright (C) 2015-2016, JYATL - Just Yet Another Testing Lab";
    comment "mailto: mcgowan (at) alum DOT mit DOT edu";
}
report_init ()
{
    om_iam
}
@include report.1
report_init 1>&2

```

### reportlib, working

Then here are the working functions.

``` {.bash .rundoc-block rundoc-language="sh" rundoc-tangle="./inc/report.1" rundoc-comments="link" rundoc-padline="no"}
function report_emptyfile
{ 
    [[ -s $1 ]] && return 1;
    report_usage File: is empty
}
function report_isfile
{ 
    [[ -f $1 ]] || return 1;
    report_usage $1 IS a file and should not be
}
function report_needcount
{ 
    [[ $2 -ge $1 ]] && return 1;
    usage need at least $1 arg/s $(shift 2; echo $*)
}
function report_notbase
{ 
    [[ $(basename $PWD) == "$1" ]] && return 1;
    comment change to "$1" directory
}
function report_notblockspecial
{ 
    [[ -b $1 ]] && return 1;
    report_usage $1 is NOT a blockspecial file
}
function report_notcalledby
{ 
    set ${1:-/dev/null} $(myname 3) non-Existant-function;
    [[ $2 == $1 ]] && return 1;
    report_usage was NOT called by $1.
}
function report_notcharacterspecial
{ 
    [[ -c $1 ]] && return 1;
    report_usage $1 is NOT a characterspecial file
}
function report_notdirectory
{ 
    [[ -d $1 ]] && return 1;
    report_usage $1 is NOT a Directory
}
function report_notexecutable
{ 
    [[ -x $1 ]] && return 1;
    report_usage $1 is NOT an executable file
}
function report_notexisting
{ 
    [[ -e $1 ]] && return 1;
    report_usage $1 is NOT an existing file
}
function report_notfunction
{ 
    set ${1:-/dev/null};
    isfunction $1 && return 1;
    report_usage $1 is NOT a Function
}
function report_notgroupiseuid
{ 
    [[ -G $1 ]] && return 1;
    report_usage $1 is NOT a file with groupiseuid
}
function report_notlargeenough
{ 
    [[ $2 -ge $1 ]] && return 1;
    report_usage $1 $(echo 1 $1, 2 $2 $(shift 2; echo $*))
}
function report_notnonzerostring
{ 
    [[ -n $1 ]] && return 1;
    report_usage $1 is NOT a nonzerolengthstring
}
function report_notowneriseuid
{ 
    [[ -O $1 ]] && return 1;
    report_usage $1 is NOT a file with owneriseuid
}
function report_notpipe
{ 
    [[ -p /dev/stdin ]] && return 1;
    report_usage is NOT reading a pipe
}
function report_notreadable
{ 
    [[ -r $1 ]] && return 1;
    report_usage $1 is NOT a readable file
}
function report_notsetgroupid
{ 
    [[ -g $1 ]] && return 1;
    report_usage $1 is NOT a file with setgroupid
}
function report_notsetuserid
{ 
    [[ -u $1 ]] && return 1;
    report_usage $1 is NOT a file with setuserid
}
function report_notsocket
{ 
    [[ -S $1 ]] && return 1;
    report_usage $1 is NOT a socket
}
function report_notstickybitset
{ 
    [[ -k $1 ]] && return 1;
    report_usage $1 is NOT a file with its stickybitset
}
function report_notsymboliclink
{ 
    [[ -L $1 ]] && return 1;
    report_usage $1 is NOT a symboliclink
}
function report_notwritable
{ 
    [[ -w $1 ]] && return 1;
    report_usage $1 is NOT a writable file
}
function report_notzerolengthstring
{ 
    [[ -z $1 ]] && return 1;
    report_usage $1 is NOT a zerolengthstring
}
function report_usage
{ 
    comment USAGE $(myname 3): $*
}
report_functions () 
{ 
    set | awk '$2 ~ /\(\)/ { print $1 }' | grep '^report_'
}
report_nofilefrom () 
{ 
    set $(eval $*) /dev/null $*;
    [[ -f $1 ]] && return 1;
    shift;
    report_usage \'$*\' did not return a file name.
}
report_notargcount () 
{ 
    [[ $2 -ge $1 ]] && return 1;
    report_usage need at least $1 arg/s: $(shift 2; echo $*)
}
report_notcommand () 
{ 
    ignore type -a $1 && return 1;
    report_usage $1 is NOT a command
}
report_notfile () 
{ 
    [[ -f $1 ]] && return 1;
    report_usage $1 is NOT a file
}
report_notfilegreaterthanzero () 
{ 
    [[ -s $1 ]] && return 1;
    report_usage $1 is NOT a filegreaterthanzero
}
report_nottrue () 
{ 
    eval "$@" && return 1;
    report_usage $@ FAILED
}
```

shdoc family
------------

### shdoc, shd~with~

The functions here operate on shell functions, and operate similar to
the three mentioned above: Java, Perl, and Python. The two most useful
functions, **shdoc** and **shd~with~** produce a function whose body is
the collected comments in what I'm calling **shdoc**, or *shell doclib
comment* format:

``` {.bash .rundoc-block rundoc-language="sh" rundoc-tangle="./inc/shdoc.0" rundoc-comments="both" rundoc-padline="no"}
@include shdoc.1
@include shdoc.2
@include shdoc.3
shdoc_init ()
{
   om_iam
}
```

``` {.bash .rundoc-block rundoc-language="sh" rundoc-tangle="./inc/shdoc.1" rundoc-comments="both" rundoc-padline="no"}
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
function shdoc_doc {
    : this is a shell doclib "shdoc" comment;
    : an shddoc comment is the first ":"-origin lines;
    : in the shell function, the rest being the executable.;
}
```

Note the result. The **shdoc~doc~** function is the first
colon-delimited lines of the **shdoc** function.

**shd~with~** is the most useful of the bunch, as it says by removing
*shd~less~* functions from shdoc results.

### shd~each~

To complete the picture, here is **shd~each~**. It's notable in that it
insists on being called by **shdoc**.

``` {.bash .rundoc-block rundoc-language="sh" rundoc-tangle="./inc/shdoc.2" rundoc-comments="both" rundoc-padline="no"}
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
shd_trim () 
{ 
    report_notfunction $1 && return 1;
    trace_call $*;
    declare -f $1 | awk ' $1 !~ /^:$/'
}

```

Note **shd~each~** produces the result for only one function, if only to
print a single function body; it insists on being called by **shdoc**.

Here's a question: *why doesn't shd~each~ have any shdoc comments?*

trace family
------------

``` {.bash .rundoc-block rundoc-language="sh" rundoc-tangle="./inc/trace.0"}
function trace_base
{ 
    printf "TRACE %s ( %s )\n" ${FUNCNAME[1]} "$*" 1>&2
}
function trace_basic
{ 
    set /tmp/$USER.y;
    declare -f trace_base | sed 's/_base/_call/' > $1;
    . $1
}
function trace_debug
{ 
    comment $PWD $(myname 2) $*;
    trap read debug
}
function trace_fbdy
{ 
    printf "TRACE %s ( %s )\n" ${FUNCNAME[1]} "$*" 1>&2;
    nlevel=${#FUNCNAME[@]};
    for ((i = 1; i < $nlevel; i++))
    do
        set ${BASH_LINENO[$i-1]} ${FUNCNAME[$i]} ${BASH_ARGV[0]};
        [[ $1 -lt 0 ]] && set 0 $2 /dev/null;
        trace_level $* $i $nlevel;
    done
}
function trace_help
{ 
    echo trace functions:;
    sfg trace_ | sed 's/^/  /'
}
function trace_init
{ 
    declare -f om_iam >/dev/null || { comment $(myname) OM_IAM is NOT a function; return 1; }
    om_iam
}
function trace_isOFF
{ 
    local tr=$(trace_state);
    trace_off;
    eval $*;
    eval $tr
}
function trace_easy
{
    echo $* 1>&2
}
function trace_isOKto
{ 
    [[ $1 == trace_${1/trace_} ]] || echo $1
}
function trace_level
{ 
    line=$(sed -n ${1}p $3);
    printf " %d / %d \t%-14s\t%4d: %s\n" $4 $5 "$2()" $1 "$line" 1>&2
}
function trace_on
{ 
    eval "trace_call () { trace_stderr \"\$@\"; }";
    # for the moment, disable this tracing mechanism
    # eval "trace_call () { return; }";
    trace_set trace_on trace_off
}
function trace_off
{ 
    eval "trace_call () { return; }";
    trace_set trace_off trace_on
}
function trace_set
{ 
    case $1.$2 in 
        trace_on.trace_off | trace_off.trace_on)
            setenv TRACE_STATE ${1};
            setenv TRACE_NOT ${2}
        ;;
        trace_on.*)
            trace_set $1 trace_off
        ;;
        trace_off.*)
            trace_set $1 trace_on
        ;;
    esac
}
function trace_show
{ 
    : show a basic, easy trace_call;
    trace_replace easy
}
trace_simple () 
{ 
    : ~ arg ...;
    : prints Calling Function and passed arguments to STDERR;
    pa=${FUNCNAME[1]:-COMMANDLINE};
    printf "TRACE %s\t%s\n" "$pa" "$*" 1>&2
}
trace_replace () 
{ 
    : show a basic, simple trace_call;
    : returns trace_{arg} as trace_call;
    : or returns trace_call   
    case ${1:-call} in
         base | call | easy | simple )
         declare -f trace_${1} | sed "s/$1/call/"
         ;;
    esac
}
function trace_state
{ 
    echo $TRACE_STATE
}
function trace_summary
{ 
    set ~/lib/trace.log;
    trace_call $*;
    cat $1 | awk '

    $1 ~ /TRACE/ && ( $3 ~ /fm/ || $3 ~ /@/)   { 

                      count[$2 "\t" $4]++; next 
    }
    $1 ~ /HOURLY/   { for (c in count) {
                        printf "SUM\t%6d\t%s\n", count[c], c
                        }
                      print $0
              nc = 0
                      delete count
                    }
    '
}
function trace_tmpoff
{ 
    stack_push $(trace_state);
    trace_off;
    $*;
    trace_set $(stack_pop)
}
function trace_tmpon
{ 
    stack_push $(trace_state);
    trace_on;
    $*;
    trace_set $(stack_pop)
}
function trace_toggle
{ 
    trace_set $TRACE_NOT $TRACE_STATE;
    $(trace_state);
    trace_state
}
```

utility functions
-----------------

Note the shell idiom in the **shd~top~** function. It's a convenient
shorthand to list a collection of similar names. In this case, this
*shdlib* conventionally defines functions whose name begins with
*shd\_*.

``` {.bash .rundoc-block rundoc-language="sh" rundoc-tangle="./inc/shdoc.3" rundoc-comments="both" rundoc-padline="no"}
shd_top () 
{ 
    echo shdoc shd_{oc,each,with,test}
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
    set $(sfg shd_);
    : doit shdoc $*;
    shd_with $*;
    shd_each $*;
    declare -f shd_test | grep -v '^ *:' 1>&2
}
```

The standard practice for such a family has the executable `om_iam`
which establishes the function family of functions sharing the common
preface.

For example:

``` {.example}
$ shd top       # calls shd_top, returning
shdoc shd_oc shd_each shd_with shd_test
```

Tangling
========

The installation script
-----------------------

``` {.bash .rundoc-block rundoc-language="sh" rundoc-tangle="./src/shelf.install" rundoc-padline="no"}

    install_bin shelf

```

the top shelf
-------------

``` {.txt .rundoc-block rundoc-language="txt" rundoc-tangle="./inc/shelf.all" rundoc-padline="no"}
@include util.0
@include report.0
@include shdoc.0
@include trace.0
@include om.0
@include shelf.0
```

``` {.txt .rundoc-block rundoc-language="txt" rundoc-tangle="./inc/shelf.0" rundoc-padline="no"}
shelf_init ()
{
     om_init
     om_iam
     report_init
     shdoc_init
     trace_init
}
shelf_init 1>&2
```

Verification
============

This section supplies and documents the functions and procedures to
verify the `shelflib` conformance to this standard. A bit chicken-or-egg
type of problem. That's the nature of the beast.

References
==========

If reading on paper, this document is found on-line at
<http://mcgowans.org/marty3/commonplace/software/shdoc.html>

" the [shdoc function family](./shdoc.org)

-   the [SHELF Standard](./shelf.org)
-   my [Commonplace Book](../book.org)

