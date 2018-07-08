
using REPL

terminal = nothing  # The user terminal

function __init__()
    global terminal
    terminal = REPL.Terminals.TTYTerminal(get(ENV, "TERM", Sys.iswindows() ? "" : "dumb"), stdin, stdout, stderr)
end

mutable struct TreeState
    pagesize::Int
    pageoffset::Int

    lastHeight::Int
end

TreeState() = TreeState()

function request(obj)
    cursor = 0

    state = printTree(term.out_stream, obj)

    raw_mode_enabled = enableRawMode(term)
    raw_mode_enabled && print(term.out_stream, "\x1b[?25l") # hide the cursor
    try
        while true
            c = readKey(term.in_stream)

            # TODO: keyhandling

            state = printTree(term.out_stream, obj, state)
        end
    finally
        # always disable raw mode even even if there is an
        # exception in the above loop
        if raw_mode_enabled
            print(term.out_stream, "\x1b[?25h") # unhide cursor
            disableRawMode(term)
        end
    end
end

function printNode(buf, obj, idx)
    node = treenode(obj, idx)

    tmpbuf = IOBuffer()
    if hastreeview(node)

    else
        current ? print(tmpbuf, "[-] ") : print(buf, " -  ")
        treelabel(tmpbuf, obj, idx)
    end

    print(buf, String(take!(tmpbuf)))
end

function printTree(buf, obj, state)
    tmpbuf = IOBuffer()

    treelabel(tmpbuf, obj)
    println(tmpbuf)
    for i in 1:numberofnodes(obj)
        print(tmpbuf, "\x1b[2K") # clear line

        printNode(tmpbuf, obj, i)
    end

    print(buf, String(take!(tmpbuf)))
    return state
end

function printTree(buf, obj)
    state = TreeState()

    # initialization

    return printTree(buf, obj, state)
end
