undotslash()
{ 
    sed -e "s:^\.\/::" "$@"
}
