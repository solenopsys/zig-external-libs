
# base 

buildah  bud --layers -t zig_builder -f zig_builder.dockerfile


# Examples

buildah  bud --layers -t level -f level.dockerfile

buildah  bud --layers -t leveldb -f leveldb.dockerfile  

buildah  bud --layers -t ubpf -f ubpf.dockerfile