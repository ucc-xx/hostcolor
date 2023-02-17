#!/usr/bin/env python
#
# Takes [hostname] = [label] + [number] (e.g. dns1 or web7) and calculates
# a color (256 Format) for shell use. Color range is 18-229. Only last char
# of [number] is used, null is treated as 0.
#
# Notice: The sh and py versions of host-color have a slight math. varinace
# and are not to be used interchangebly (e.g. web1 sh->50 and py->53).

import getopt, hashlib, sys

def usage():
    print("usage: " + sys.argv[0] + "  --help")
    print("usage: " + sys.argv[0] + "  [--pretty-print] [--salt=salt] hostname [hostname [hostname [...]]] \n")

def version():
    print("host-color v1.1py ## 2021-06-01 ## ucc-xx \n")

def help():
    version()
    usage()
    print('''
    Takes [hostname] = [label] + [number] (e.g. dns1 or web7) and calculates
    a color (256 Format) for shell use. Color range is 18-229. Only last char
    of [number] is used, null is treated as 0.
   
    This works well for [number] 0-2 and ok up to 3. After that there might be
    collisions. There are up to 66 color families with 3 destinct colors if all
    families stay under 4 members. (e.g. fam0 22-24 and fam1 25-27 overlap
    when one of the families has a fourth member fam1-4 is 25).

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
''')

def main():
    try:
        opts, args = getopt.getopt(sys.argv[1:], "hps:", ["help", "pretty-print","salt="])
    except getopt.GetoptError as err:
        usage()
        print(err)
        sys.exit(2)
    slt = '' #good default
    prt = 0 #pretty-print off
    for o, a in opts:
        if o in ("-h", "--help"):
            help()
            sys.exit()
        elif o in ("-s", "--salt"):
            slt = a
        elif o in ("-p", "--pretty-print"):
            prt = 1
        else:
            assert False, "unhandled option"
    hsts = len(args) - 1
    pos = 0
    while (hsts >= pos):
        hst = args[pos] #hostname
        lab = ''.join(x for x in hst if x.isalpha()) #label
        num = (''.join(x for x in hst if x.isdigit()))[-1:] #number
        hsh = '0x' + hashlib.md5((slt + lab).encode('utf-8')).hexdigest()[:2] #hash 0-ff
        val = int(hsh,16) / 255.0 #value 0-1
        fam = round(val * 66) #family
        if not num:
            mem = 0
        else:
            mem = int(num)
        if (fam % 2) == 0: #even or odd family?
            odd = -1
        else:
            odd = 1
        if mem > 5: #mod of member
            mod = (mem - 4) * odd
        else:
            mod = (mem - 1) * (odd * -1)
        col = fam * 3 + 23 + mod
        #debug
        #print (" %s: %.2f %d %d %d -> \033[38;5;%dm %s \033[0m %d" % (hsh, val, fam, mem, mod, col, hst, col))
        if prt:
            print (" \033[48;5;%dm    \033[0m %d        \033[38;5;%dm %s \033[0m" % (col, col, col, hst))
        else:
            print("%d" % col)
        pos += 1

if __name__ == "__main__":
    main()
