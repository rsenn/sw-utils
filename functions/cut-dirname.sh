cut-dirname()
{ 
    sed "s,\\(.*\\)/\\([^/]\\+/\\?\\)${1//./\\.}\$,\2,"
}