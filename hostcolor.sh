#!/usr/bin/env sh
#
# Takes [hostname] = [label] + [number] (e.g. dns1 or web7) and calculates
# a color (256 Format) for shell use. Color range is 18-229. Only last char
# of [number] is used, null is treated as 0.
#
# Notice: The sh and py versions of host-color have a slight math. varinace
# and are not to be used interchangebly (e.g. web1 sh->50 and py->53).

usage () {
    echo "usage: $0 --help"
    echo "usage: $0 [--pretty-print] [--salt=salt] hostname [hostname [hostname [...]]]"
    echo ""
}

version () {
    echo "host-color v1.1sh ## 2021-06-01 ## ucc-xx"
    echo ""
}

help () {
    version
    usage
    cat << HELPDOC
    Takes [hostname] = [label] + [number] (e.g. dns1 or web7) and calculates
    a color (256 Format) for shell use. Color range is 18-229. Only last char
    of [number] is used, null is treated as 0.
    
    This works well for [number] 0-2 and ok up to 3. After that there might be
    collisions. There are up to 66 color families with 3 destinct colors if all
    families stay under 4 members. (e.g. fam0 22-24 and fam1 25-27 overlap
    when the family 0 has a fourth member: fam0-4 is 25).
    
    Notice: abc32xyz1 is interpreted as label = "abcxyz" number = "321"
    
    Families have a head, defining the name (i.e. fam53), the head is allways
    member #1, not #0. This family name is fam[0-66] and the color of the head
    is calculated by [0-66] * 3 + 23 - so fam0-1 is 23 and fam66-1 is 221.
    
    Even number families count up and jump down after member #5 and continue
    decending until member #9. Odd number families vice versa. The col of any
    familiy member can be calculated as famX-1 col + mod. The mod is obtained
    using the member number. The following table elaborates on this:
    
           mem  col  mod                      mem  col  mod
       fam0-0    22   -1 =  mem-1         fam55-0   189  +1 = (mem-1) *-1
            1    23   +0 =  mem-1               1   188  +0 = (mem-1) *-1
        0   2    24   +1 =  mem-1          5    2   187  -1 = (mem-1) *-1
            3    25   +2 =  mem-1          5    3   186  -2 = (mem-1) *-1
        ^   4    26   +3 =  mem-1               4   185  -3 = (mem-1) *-1
        E   5    27   +4 =  mem-1          ^    5   184  -4 = (mem-1) *-1
        V   6    21   -2 = (mem-4) *-1     O    6   190  +2 =  mem-4
        E   7    20   -3 = (mem-4) *-1     D    7   191  +3 =  mem-4
        N   8    19   -4 = (mem-4) *-1     D    8   192  +4 =  mem-4
            9    18   -5 = (mem-4) *-1          9   193  +5 =  mem-4
    
    Notice: The sh and py versions of host-color have a slight math. varinace
    and are not to be used interchangebly (e.g. web1 sh->50 and py->53).

        -> don't like the colors - use the --salt (-s) to modyfiy.

HELPDOC
}

main () {
    _init_md5
    slt='' #good default
    prt=0  #pretty-print off
    while [ $# -gt 0 ] ; do
        case ${1} in
            -p|--pretty-print)  prt=1 && shift && continue ;;
            -s|--salt)          slt=${2} && shift && shift && continue ;;
            -s=*|--salt=*)      slt=$(echo ${1} | cut -d= -f2) && shift && continue ;;
            *)                  break ;;
        esac
    done
    while [ $# -gt 0 ] ; do
        hst=${1}  #hostname
        lab=$(echo ${1}| sed -e 's/[0-9]*//g') #label
        num=$(echo ${1}| sed -e 's/[^0-9]*//g') #number
        hsh=$($_hash "$slt$lab" | tr a-z A-Z) #make uppercase #hash 0-FF
        val=$(echo "ibase=16; h=$hsh; ibase=10; scale=2;  h/ FE" | bc) #value 0-1
        fam=$(echo "v=$val * 66; scale=0; v/1" | bc) #family
        mem=${num:-0}
        mod=$(echo "scale=0; odd=(($fam % 2) * 2) -1; mem = $mem ; if (mem > 5 ) (mem -4) * odd else (mem -1) * (odd * -1) " | bc)
        col=$(echo "($fam * 3) + 23 + $mod" | bc)
        #debug
        #printf " %s: %s %d %d %d -> \033[38;5;%dm %s \033[0m %d	%s %s \n" $hsh $val $fam $mem $mod $col $hst $col $_hash "$_hashsum"
        if [ 0 -eq $prt ] ; then
            echo $col
        else
            printf " \033[48;5;%dm    \033[0m %d	\033[38;5;%dm %s \033[0m \n"  $col $col $col $hst
        fi
        shift
    done
}

_init_md5 () {
    command -v md5 >/dev/null 2>&1 && _hash="_md5" || _init_md5sum
}

_init_md5sum () {
    command -v md5sum >/dev/null 2>&1 && _hashsum="md5sum" || _hashsum="openssl md5 -r"
    _hash="_md5sum"
}

_md5 () {
    md5 -qs $1 | cut -b1-2
}

_md5sum () {
    echo -n $1 | $_hashsum | cut -b1-2
}

if [ "-h" == "$1" -o "--help" == "$1" ] ; then
    help
else
    main $*
fi
