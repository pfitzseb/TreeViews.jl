module TreeViews

"""
    hastreeview(x::T)::Bool

Called by a frontend to decide whether a tree view for type `T` is available.
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

Prints `x`'s tree header to `io`.
"""
treelabel(io::IO, x::T, mime::MIME"text/plain" = MIME"text/plain"()) where {T} = show(io, mime, T)

"""
    treelabel(io::IO, x::T, i::Integer, mime::MIME"text/plain" = MIME"text/plain"())

Prints the label of `x`'s `i`-th child to `io`.
"""
function treelabel(io::IO, x::T, i::Integer, mime::MIME"text/plain" = MIME"text/plain"()) where {T}
  show(io, mime, Text(String(fieldname(T, i))))
end

"""
    treenode(x::T, i::Integer)

Returns the `i`-th node of `x`, which is usually printed by the display frontend next to
the corresponding `treelabel`.
"""
treenode(x::T, i::Integer) where {T} = getfield(x, fieldname(T, i))

end # module
