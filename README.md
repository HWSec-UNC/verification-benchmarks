# Hardware Security Verification Benchmarks
This reposititory contains security properties for the formal verification of open-source processors and SoCs. In the directory corresponding to each design is a set of properties written as SystemVerilog Assertions (SVA). Each property is documented with a description of the bug it finds and is tagged with the related CWE(s). The README in each directory describes the snapshot of the design found in that folder, including the particular commit of the design included and any bugs that have been inserted.

We encourage the community to contribute new properties and pull requests are welcome!

These properties are first described in [_anonymized submission_]. As part of that submission, we describe a literature review of papers related to formal properties in hardware security verification. The papers included in that literature review are listed here.

| Paper Title | Paper Type | Citation |
|---|:---:|:---:|
| HardFails: Insights into Software-Exploitable Hardware Bugs | FV | [15] |
| RTL-ConTest: Concolic Testing on RTL for Detecting Security Vulnerabilities | FV | [43] |
| End-to-End Automated Exploit Generation for Validating the Security of Processor Designs | FV | [70] |
| Design of Access Control Mechanisms in Systems-on-Chip with Formal Integrity Guarantees | FV | [41] |
| DIVAS: An LLM-based End-to-End Framework for SoC Security Analysis and Policy-based Protection | PG | [51] |
| A Formal Approach to Confidentiality Verification in SoCs at the Register Transfer Level | FV | [48] |
| Isadora: automated information-flow property generation for hardware security verification | PG | [17] |
| Transys: Leveraging Common Security Properties Across Hardware Designs | PG | [72] |
| SPECS: A Lightweight Runtime Mechanism for Protecting Software from Security-Critical Processor Bugs | FV | [33] |
| AGILE: Automated Assertion Generation to Detect Information Leakage Vulnerabilities | FV + PG | [20] |
| SoC Security Verification using Property Checking | FV | [24] |
| Evaluating Security Specification Mining for a CISC Architecture | PG | [18] |
| Fault Attacks on Access Control in Processors: Threat, Formal Analysis and Microarchitectural Mitigation | FV | [3] |
| LLM-assisted Generation of Hardware Assertions | PG | [38] |
| HUnTer: Hardware Underneath Trigger for Exploiting SoC-level Vulnerabilities | FV | [54] |
| Sylvia: Countering the Path Explosion Problem in the Symbolic Execution of Hardware Designs | FV | [57] |
| Countering the Path Explosion Problem in the Symbolic Execution of Hardware Designs | FV | [56] |
| Applying Unique Program Execution Checking in the development flow of industrial IoT devices to prevent vulnerabilities for side-channel attacks | FV | [62] |
| Mining Secure Behavior of Hardware Designs | PG | [16] |
| Unique Program Execution Checking: A Novel Approach for Formal Security Analysis of Hardware | FV | [52] |
| Unlocking Hardware Security Assurance: The Potential of LLMs | PG | [44] |
| Exploring the Abyss? Unveiling Systems-on-Chip Hardware Vulnerabilities Beneath Software | FV | [53] |
| Ensuring Hardware Robustness via Security Verification | FV | [42] |
| WASIM: A Word-level Abstract Symbolic Simulation Framework for Hardware Formal Verification | FV | [21] |
| Register transfer level information flow tracking for provably secure hardware design | FV | [4] |
| Hardware verification using software analyzers | FV | [47] |
| Property specific information flow analysis for hardware security verification | FV | [36] |
| Automated test generation for activation of assertions in RTL models | FV | [60] |
