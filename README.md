# hostcolor

Script collection to calculate colours from hostnames.

## how to run it

You can run the scripts from a shell.

```console
./hostcolor.sh --help
./hostcolor.sh [--pretty-print] [--salt=salt] hostname [hostname [hostname [...]]]
```

## what does it do

From the in-script documentation:

```shell
    Takes [hostname] = [label] + [number] (e.g. dns1 or web7) and calculates
    a color (256 Format) for shell use. Color range is 18-229. Only last char
    of [number] is used, null is treated as 0.
    
    This works well for [number] 0-2 and ok up to 3. After that there might be
    collisions. There are up to 66 color families with 3 destinct colors if all
    families stay under 4 members. (e.g. fam0 22-24 and fam1 25-27 overlap
    when one of the families has a fourth member fam1-4 is 25).
    
    Notice: abc32xyz1 is interpreted as lable = "abcxyz" number = "321"
    
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

```

## how to affect the output

`-h` `--help`	show the version, usage and in-script documentation only.

`-p` `--pretty-print`	print a table displaying the colour, its number and the tinted hostname.

```console
% ./hostcolor.sh -p test foo1 foo2
 ████ 27	 test  
 ████ 155	 foo1  
 ████ 156	 foo2  
```
_…kinda silly without colour._

`-s=` `--salt=`	add a salt to the hostnames in case you don't like the colors suggested

```console
% ./hostcolor.sh test foo1 foo2
27
155
156
```

```console
% ./hostcolor.sh --salt=spice test foo1 foo2
160
209
210
```

### debug

As of version 1.1 there are debug statements on lines `88`_sh_ and `103`_py_ that are commented out.

## license

As some jurisdictions require a licence, we have opted for Creative Commons Zero v1.0 Universal.
