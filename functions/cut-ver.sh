
cut-ver()
{ 
    sed 's,[-_][.0-9]\+[^-_]*,, ; s,[-_][[:alnum:]]*[.0-9]\+[^-_]*,,' "$@"

}
