use warnings;
use strict;

while (<>) {
    s/(\w\w) (\w\w) (\w\w) (\w\w)/$4$3$2$1/g;
    print;
}
