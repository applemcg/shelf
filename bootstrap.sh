
#  ------------------------- preserve the original PATH --

: ${OPATH:=$PATH}

# -------------------------------- development defaults --

#  EDIT to suit your Needs
COMBINE_FROM=./inc
COMBINE_TO=./src
COMBINE_SUF=all
COMBINE_OUT=out
INSTALL_TO=$HOME/Dropbox/bin

pushd $COMBINE_FROM

    # ---------------------------- source the fragments --

    combine_inc=$(pwd)
    
    for file in {install,combine}.?;  do
       [[ -f $file ]] || continue
       . $file
       echo === $file ===
    done
    
   # --------------------- here is a bootstrap INCLUDE  --

    ln -f include.all include
    chmod +x include
   
   # ------------------------------ put it on the PATH  -- 

    PATH=$combine_inc:$OPATH
popd
# ------------------------------------- simulate Source --

combine_init
# --------------------------------- do the installation --

install_combine
# ------------------------ remove the bootstrap include --

rm -f $combine_inc/include
# ------------------------------------ restore the PATH --

PATH=$INSTALL_TO:$OPATH
