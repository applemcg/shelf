
# --------- while testing in the same shell, clean up residuals --

unset $(
    set | awk -F= '     \
          $1 ~ /^COMBINE_/ ||   \
               /^combine/  ||   \
               /^install/  { sub(/[(][)]/," "); print $1 }

          '
      ) 

. ./bootstrap.sh
