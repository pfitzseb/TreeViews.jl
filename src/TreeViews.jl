module TreeViews

include("repl/Tree.jl")

# generic API
"""
    hastreeview(x)::Bool

Called by a frontend to decide whether a tree view should be displayed.
Defaults to `false`.
"""
hastreeview(x) = false

"""
    numberofnodes(x)

Number of direct descendents.
Defaults to `fieldcount(typeof(x))`.
"""
numberofnodes(x::T) where {T} = fieldcount(T)

"""
    treelabel(io::IO, x, mime = MIME"text/plain"())


"""
treelabel(io::IO, x::T, mime::MIME"text/plain" = MIME"text/plain"()) where {T} = show(io, mime, T)

"""

"""
treelabel(io::IO, x::T, i::Integer, mime::MIME"text/plain" = MIME"text/plain"()) where {T} =
  show(io, mime, Text(String(fieldname(T, i))))

"""

"""
treenode(x::T, i::Integer) where {T} = getfield(x, fieldname(T, i))

end # module
