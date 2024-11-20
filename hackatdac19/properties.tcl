assert(\~(((j==6) && access\_ctrl\_i[i][7][priv\_lvl\_i]))
assert(\~(debug\_mode\_q && umode\_i) \|\| (riscv::PRIV\_LVL\_M))
assert( ((csr\_we \|\| csr\_read) && (csr\_addr.address==riscv::CSR\_MEPC)) \|-> csr\_exception\_o.valid == 1'b1)
assert(\~((csr\_exception\_i.valid && csr\_exception\_i.cause[63] && commit\_instr\_i[0].fu != CSR) \|\| (amo\_valid\_commit\_o)))  this is wrong. another idea: assert {amo\_valid\_commit\_o \|-> (exception\_o != csr\_exception\_i)}
assert {amo\_valid\_commit\_o \|-> \~commit\_ack\_o[1]}
assert {amo\_valid\_commit \|-> (flush\_ctrl\_if && flush\_ctrl\_id && flush\_ctrl\_ex)}
assert {tvm\_o \|-> (csr\_rdata\_o != satp\_q)}
assert {tvm\_o \|-> (satp\_d != csr\_wdata\_i)
assert {(priv\_lvl != $past(priv\_lvl)) \|-> (flush\_ctrl\_if && flush\_ctrl\_id && flush\_ctrl\_ex)}
assert {(instret\_q != $past(instret\_q)) \|-> debug\_mode\_q}
assert {halt\_o \|-> ex\_valid\_i}
