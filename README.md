# Hardware Security Verification Benchmarks
This reposititory contains security properties for the formal verification of open-source processors and SoCs. In the directory corresponding to each design is a set of properties written as SystemVerilog Assertions (SVA). Each property is documented with a description of the bug it finds and is tagged with the related CWE(s). The README in each directory describes the snapshot of the design found in that folder, including the particular commit of the design included and any bugs that have been inserted.

We encourage the community to contribute new properties and pull requests are welcome!

These properties are first described in [_anonymized submission_]. As part of that submission, we describe a literature review of papers related to formal properties in hardware security verification. The papers included in that literature review are listed here.

| Paper Title | Paper Type | Citation |
|---|:---:|:---:|
| HardFails: Insights into software-exploitable hardware bugs | FV | [15] |
| RTL-ConTest: Concolic testing on RTL for detecting security vulnerabilities | FV | [43] |
| End-to-End automated exploit generation for validating the security of processor designs | FV | [70] |
| Design of access control mechanisms in Systems-on-Chip with formal integrity guarantees | FV | [41] |
| DIVAS: An LLM-based end-to-end framework for SoC security analysis and policy-based protection | PG | [51] |
| A Formal approach to confidentiality verification in SoCs at the register transfer level | FV | [48] |
| Isadora: Automated information-flow property generation for hardware security verification | PG | [17] |
| Transys: Leveraging common security properties across hardware designs | PG | [72] |
| SPECS: A lightweight runtime mechanism for protecting software from security-critical processor bugs | FV | [33] |
| AGILE: Automated assertion generation to detect information leakage vulnerabilities | FV + PG | [20] |
| SoC security verification using property checking | FV | [24] |
| Evaluating security specification mining for a CISC architecture | PG | [18] |
| Fault attacks on access control in processors: Threat, formal analysis and microarchitectural mitigation | FV | [3] |
| LLM-assisted generation of hardware assertions | PG | [38] |
| HUnTer: Hardware underneath trigger for exploiting SoC-level vulnerabilities | FV | [54] |
| Sylvia: Countering the path explosion problem in the symbolic execution of hardware designs | FV | [57] |
| Countering the path explosion problem in the symbolic execution of hardware designs | FV | [56] |
| Applying unique program execution checking in the development flow of industrial IoT devices to prevent vulnerabilities for side-channel attacks | FV | [62] |
| Mining secure behavior of hardware designs | PG | [16] |
| Unique program execution checking: A novel approach for formal security analysis of hardware | FV | [52] |
| Unlocking hardware security assurance: The potential of LLMs | PG | [44] |
| Exploring the abyss? Unveiling Systems-on-Chip hardware vulnerabilities beneath software | FV | [53] |
| Ensuring hardware robustness via security verification | FV | [42] |
| WASIM: A aord-level abstract symbolic simulation framework for hardware formal verification | FV | [21] |
| Register transfer level information flow tracking for provably secure hardware design | FV | [4] |
| Hardware verification using software analyzers | FV | [47] |
| Property specific information flow analysis for hardware security verification | FV | [36] |
| Automated test generation for activation of assertions in RTL models | FV | [60] |
