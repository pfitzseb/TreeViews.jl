
using REPL

include("utils.jl")

terminal = nothing  # The user terminal

function __init__()
    global terminal
    terminal = REPL.Terminals.TTYTerminal(get(ENV, "TERM", Sys.iswindows() ? "" : "dumb"), stdin, stdout, stderr)
end

mutable struct Tree
    obj

    pagesize::Int
    pageoffset::Int
    lastHeight::Int

    expanded::Vector{Any}
end

function toggle(t::Tree, cursor)
    if isempty(t.expanded)
        push!(t.expanded, (index  = (cursor,),
                           length = hastreeview(treenode(t.obj, cursor+1)) ?
                                    numberofnodes(treenode(t.obj, cursor+1)) : 0))
    else

    end
end

function isexpanded(t::Tree, cursor)
    isempty(t.expanded) && (return false)
    return true
end

Tree(obj) = Tree(obj, 100, 0, 0, [])

indent(level) = "  "

function limitLineLength(strs, term_width)
    outstrs = String[]
    for str in strs
        if length(str) >= term_width
            while length(str) >= term_width
                push!(outstrs, str[1:term_width])
                str = str[term_width:end]
            end
        else
            push!(outstrs, str)
        end
    end
    outstrs
end

function printTree(io::IO, t::Tree, cursor; init=false, level=0)
    obj = t.obj

    buf = IOBuffer()

    if init
        t.pageoffset = 0
    else
        # move cursor to beginning of current menu
        print(buf, "\x1b[999D\x1b[$(t.lastHeight)A")
        # clear display until end of screen
        print(buf, "\x1b[0J")
    end

    term_width = REPL.Terminals.width(terminal)

    # header
    tb = IOBuffer()
    treelabel(tb, obj)
    println(buf, join(limitLineLength([String(take!(tb))], term_width-(2*level + 10)), '\n'))

    # nodes
    for i in 1:numberofnodes(obj)
        print(buf, "\x1b[2K")

        cursor = printNode(buf, t, i, cursor, term_width, level=level+1)

        # dont print an \r\n on the last line
        i != numberofnodes(obj) && print(buf, "\r\n")
    end

    str = String(take!(buf))

    t.lastHeight = count(c -> c == '\n', str)

    print(io, str)
    cursor
end

function printNode(buf::IOBuffer, t::Tree, idx::Int, cursor, term_width::Int; level::Int = 0)
    obj = t.obj
    node = treenode(obj, idx)

    current = cursor == 0
    cursor -= 1

    tmpbuf = IOBuffer()
    if hastreeview(node)
        cursor = printTreeChild(tmpbuf, t, sprint(io -> treelabel(io, obj, idx)), node, cursor, term_width, level = level)
    else
        current ? print(tmpbuf, "[-] ") : print(buf, " -  ")
        treelabel(tmpbuf, obj, idx)
    end
    str = join(split(String(take!(tmpbuf)), '\n'), "\n"*indent(level))
    print(buf, str)

    cursor
end

function printTreeChild(buf::IOBuffer, t, label, child, cursor, term_width::Int; level::Int = 0)
    cur = cursor == -1
    symbol = numberofnodes(child) > 0 ? isexpanded(t, child) ? "▼" : "▶" : " "

    cur ? print(buf, "[$symbol] ") : print(buf, " $symbol  ")

    if isexpanded(t, cursor)
        tbb = IOBuffer()
        # header
        tb = IOBuffer()
        treelabel(tb, child)
        println(tbb, join(limitLineLength([String(take!(tb))], term_width-(2*level + 10)), '\n'))

        # nodes
        for i in 1:numberofnodes(obj)
            print(tbb, "\x1b[2K")

            cursor = printNode(tbb, t, i, cursor, term_width, level=level+1)

            # dont print an \r\n on the last line
            i != numberofnodes(child) && print(tbb, "\r\n")
        end

        str = String(take!(tbb))

        t.lastHeight = count(c -> c == '\n', str)

        print(buf, str)
    else
        # only print header
        tb = IOBuffer()
        treelabel(tb, child)
        print(buf, join(limitLineLength([String(take!(tb))], term_width-(2*level + 10)), '\n'))
    end

    cursor
end

request(m::Tree) = request(terminal, m)

cancel(::Tree) = nothing

function request(term::REPL.Terminals.TTYTerminal, m::Tree)
    cursor = 0

    printTree(term.out_stream, m, cursor, init=true)

    raw_mode_enabled = enableRawMode(term)
    raw_mode_enabled && print(term.out_stream, "\x1b[?25l") # hide the cursor
    try
        while true
            c = readKey(term.in_stream)

            if c == Int(ARROW_UP)
                if cursor > 0
                    cursor -= 1
                end
            elseif c == Int(ARROW_DOWN)
                cursor += 1
            elseif c == 13 # <enter>
                # will break if pick returns true
                toggle(m, cursor)
            elseif c == UInt32('q')
                cancel(m)
                break
            elseif c == 3 # ctrl-c
                cancel(m)
                break
            else
                # will break if keypress returns true
                keypress(m, c) && break
            end

            printTree(term.out_stream, m, cursor)
        end
    finally
        # always disable raw mode even even if there is an
        #  exception in the above loop
        if raw_mode_enabled
            print(term.out_stream, "\x1b[?25h") # unhide cursor
            disableRawMode(term)
        end
    end
    println(term.out_stream)
end
