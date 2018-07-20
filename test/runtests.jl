using Test

import TreeViews: hastreeview, numberofnodes, treelabel, treenode

# test for sane defaults
struct TVT_default
    a
    b
    c
    d
end

teststruct = TVT_default(1, "asd", UInt8(2), 22.22)

hastreeview(x::TVT_default) = true

@test hastreeview(teststruct) == true
@test numberofnodes(teststruct) == 4
@test sprint(io -> treelabel(io, teststruct)) == "TVT_default"
@test sprint(io -> treelabel(io, teststruct, 3)) == "c"
@test treenode(teststruct, 3) == teststruct.c

# customization
struct TVT_customized
    a
    b
    c
    d
end

teststruct = TVT_customized(1, "asd", UInt8(2), 22.22)

hastreeview(::TVT_customized) = true

numberofnodes(x::TVT_customized) = 2
treelabel(io::IO, x::TVT_customized) = print(io, "customized")
function treelabel(io::IO, x::TVT_customized, i::Integer)
    i <= 2 || throw(BoundsError(x, i))
    print(io, "customized$i")
end
function treenode(x::TVT_customized, i::Integer)
    i == 1 && return x.a
    i == 2 && return TVT_default(x.b, x.c, x.c, x.d)
end

@test numberofnodes(teststruct) == 2
@test sprint(io -> treelabel(io, teststruct)) == "customized"
@test_throws BoundsError sprint(io -> treelabel(io, teststruct, 3))
@test sprint(io -> treelabel(io, teststruct, 2)) == "customized2"
@test treenode(teststruct, 1) == teststruct.a
@test treenode(teststruct, 2) == TVT_default(teststruct.b, teststruct.c, teststruct.c, teststruct.d)
