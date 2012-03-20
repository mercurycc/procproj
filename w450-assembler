#!/usr/bin/awk -f
function two_bit_binary(num)    # only works for 0 <= num <= 3
{
    if (num ~ /x/)  # x is for 'doesn't matter'
        return num
    if (num == 0)
        return "00"
    if (num == 1)
        return "01"
    if (num == 2)
        return "10"
    if (num == 3)
        return "11"
    error("not a valid register number")
}

function eight_bit_unsigned_binary(num)
{
    x = num + 0 # coerse to a numeric value
    if (x < 0)
        error("immediate value should be nonnegative")
    bin = ""
    while (x > 0)
    {
        bin = x%2 bin
        x = int(x/2)
    }

    if (length(bin) > 8) # too big a number to fit in 8 bits 
        error("unsigned value too big for 8 bits")

    while (length(bin) < 8)
        bin = "0" bin
    return bin
}

function eight_bit_twos_complement(num)
{
    x = num + 0 # coerse to a numeric value
    bin = ""
    if (x >= 0)
    {
        while (x > 0)
        {
            bin = x%2 bin
            x = int(x/2)
        }

        if (length(bin) > 7) # too big a number to fit in 8 bits 
            error("signed value too big for 8 bits")

        while (length(bin) < 8)
            bin = "0" bin
    }
    else
    {
        x = -x
        x -= 1
        while (x > 0)
        {
            bin = !(x%2) bin
            x = int(x/2)
        }

        if (length(bin) > 7) # too big a number to fit in 8 bits 
            error("signed value too big for 8 bits")

        while (length(bin) < 8)
            bin = "1" bin
    }
    return bin
}

function error(msg)
{
    print "error on line", LN ":", msg > "/dev/stderr"
    exit 1
}

function print_ic()
{
    printf "/* %02x */    ", IC
}

BEGIN {
        LN = 0
        IC = 0
}


{
    LN++
}

$1 ~ /;/ {      # comment
}

$1 ~ /^[a-zA-Z][a-zA-Z0-9]*:$/ {    # label
    print "//",$1
}

$1 ~ /^add$|^sub$|^mv$/ {
    print_ic()
    IC += 1
    if ($2 ~ /^r[0-3]$/ && $3 ~ /^r[0-3]$/) # register DIRECT
    {
        reg1 = substr($2,2) + 0
        dest = 1
        reg0 = substr($3,2) + 0

        if (reg0 == 0)  # avoid having r0 be reg0, which forces indirectness
        {
            if (reg1 == 0)
                error("can't have both operands r0 in register direct mode");

            tmp = reg0;
            reg0 = reg1;
            reg1 = tmp;
            dest = 0;
        }
    }
    else if ($2 ~ /^\[r0\]$/ && $3 ~ /^r[0-3]$/) # dest is register INDIRECT
    {
        reg0 = 0
        dest = 0
        reg1 = substr($3,2) + 0
    }
    else if ($3 ~ /^\[r0\]$/ && $2 ~ /^r[0-3]$/) # source is register INDIRECT
    {
        reg0 = 0
        dest = 1
        reg1 = substr($2,2) + 0
    }
    else
        error("invalid register operands")

    if ($1 ~ /^add$/)
        op = "000"
    else if ($1 ~ /^sub$/)
        op = "010"
    else    # $1 ~ /mv
        op = "100"
        
    print op two_bit_binary(reg1) two_bit_binary(reg0) dest
}

$1 ~ /^addi$|^subi$|^mvi$/ {
    print_ic()
    IC += 2
    if ($2 !~ /^r[0-3]$/)
        error("invalid operands");

    # no indirect for immediate instructions
    reg1 = substr($2,2) + 0
    dest = "x"
    reg0 = "xx"

    if ($3 !~ /^#-?[0-9]+$/)
        error("immediate value must be a #<number>")
    imm = substr($3,2) + 0

    if ($1 ~ /^addi$/)
        op = "001"
    else if ($1 ~ /^subi$/)
        op = "011"
    else    # $1 ~ /^mvi$/
        op = "101"

    print op two_bit_binary(reg1) two_bit_binary(reg0) dest,
          eight_bit_unsigned_binary(imm)
}

$1 ~ /^beq$|^blt$/ {
    print_ic()
    IC += 2
    dest = "x"
    if ($2 ~ /^r[0-3]$/ && $3 ~ /^r[0-3]$/)
    {
        reg1 = substr($2,2) + 0
        reg0 = substr($3,2) + 0
    }
    else
        error("invalid register operands")

    if ($4 ~ /^-?[0-9]+$/)
        off = eight_bit_twos_complement($4)
    else    # a label?
        off = $4

    if ($1 ~ /^beq$/)
        op = "110"
    else    # $1 ~ /^blt$/
        op = "111"

    print op two_bit_binary(reg1) two_bit_binary(reg0) dest, off
}
