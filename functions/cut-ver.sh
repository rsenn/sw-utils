cut-ver()
{ 
    sed -u 's,[-_][.0-9]\+.*,,' "$@"

}
