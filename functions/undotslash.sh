undotslash()
{ 
    sed -e "s:^\.\/::" "$@"
}