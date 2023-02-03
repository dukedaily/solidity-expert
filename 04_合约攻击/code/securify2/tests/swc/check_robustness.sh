for s in */* ;
do
    echo $s
    mkdir -p out/$s
    securify $s --solidity solc5.14 2>out/$s/stderr 1>out/$s/stdout 
done

