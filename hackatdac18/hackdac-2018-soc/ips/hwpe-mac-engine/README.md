# Hardware MAC Engine

The Hardware MAC Engine is an example of a Hardware Processing Engine that can be coupled with the PULP/PULPissimo hardware.
It makes use of the interface IPs 'hwpe-ctrl' and 'hwpe-stream'.
It is not meant as a particularly efficient / powerful engine, but rather as a practical example of an HWPE.
It supports two modes:
 - in 'simple_mult' mode, it takes two 32bit fixed-point streams (vectors) a, b and computes
     d = a * b
   where '*' is the elementwise product.
 - in 'scalar_prod' mode, it takes three 32bit fixed-point streams (vectors) a, b, c and computes
     d = dot(a,b) + c
It can perform this iterations multiple times, on vectors separated by an iteration stride.
It performs the multiplication at full precision (64b) and the output is normalized with a configurable shift factor.
The four streams a, b, c, d are connected to four separate ports on the external memory interface (the simplest choice possible).
