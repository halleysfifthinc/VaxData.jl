# VaxData

[![version](https://juliahub.com/docs/VaxData/version.svg)](https://juliahub.com/ui/Packages/VaxData/T8cvD)
[![pkgeval](https://juliahub.com/docs/VaxData/pkgeval.svg)](https://juliahub.com/ui/Packages/VaxData/T8cvD)
[![CI](https://github.com/halleysfifthinc/VaxData.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/halleysfifthinc/VaxData.jl/actions/workflows/CI.yml)
[![codecov.io](http://codecov.io/github/halleysfifthinc/VaxData.jl/coverage.svg?branch=master)](http://codecov.io/github/halleysfifthinc/VaxData.jl?branch=master)
[![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)

VaxData.jl is a direct port to Julia from [libvaxdata](https://pubs.usgs.gov/of/2005/1424/) [^1]. See [this report](https://pubs.usgs.gov/of/2005/1424/of2005-1424_v1.2.pdf) for an in-depth review of the underlying structure and differences between VAX data types and IEEE types.

There are 5 Vax datatypes implemented by this package: `VaxInt16`, `VaxInt32`, `VaxFloatF`,
`VaxFloatG`, and `VaxFloatD`.

# Examples

```julia
julia> one(VaxFloatF)
vaxf"1.0"

julia> -one(VaxFloatF)
vaxf"-1.0"

julia> vaxg"3.14159265358979323846264338327950"
vaxg"3.1415926535897931"

julia> vaxd"3.14159265358979323846264338327950"
vaxd"3.14159265358979323"

```

Conversion to and from each type is defined; Vax types are promoted to the next appropriately sized type supporting math operations:

```julia
promote_type(VaxFloatF, Float32)
Float32

promote_type(VaxFloatF, VaxFloatF)
Float32

promote_type(VaxFloatF, Float64)
Float64
```

[^1]: Baker, L.M., 2005, libvaxdata: VAX Data Format Conversion Routines: U.S. Geological Survey Open-File Report 2005-1424 (http://pubs.usgs.gov/of/2005/1424/).
