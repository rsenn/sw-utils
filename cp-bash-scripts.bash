MYDIR=` dirname "$0" ` 

[ $# -ge 1 ] ||set --  "$HOME"

for x in "$MYDIR"/bash_*.sh; do
  b=` basename "$x" .sh` 
 for y; do 

   cp -vf "$x" "$y"/".${b%.sh}"
  done
done
