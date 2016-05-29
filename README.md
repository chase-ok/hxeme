List of hxeme primitives: 

<
<=
=
=>
>
>=
-
/
.
.=
{}
*
+
abs
and
append
append!
apply
atom?
begin
built-in
caar
cadr
car
case
cdar
cddr
cdr
compose
cond
cons
copy
define
delay
empty?
eq?
even?
filter
fold
fold-left
fold-right
force
for-each
if
import
lambda
length
let
let*
list
list?
list*
load-module
map
new
not
null?
number?
odd?
or
pair?
procedure?
quote
random
reverse
reverse!
set!
set-car
set-cdr
string-append
string-length
throw
to-string
try
type
vector
vector-ref
vector-set!
zero?


(result of

grep -r DEFINED_ .|awk '{print $1}'|sed s/://g|grep hx$|xargs cat|grep "name : "|grep -v "//"|perl -e 'while(<>){chomp; /name\ :\ \"(.*?)\"/; print "$1\n";}'|sort|uniq > README.md 

)

Finding the function: 

grep -r "new" src|grep "func :"

grep -r "initClass(" src|grep function
