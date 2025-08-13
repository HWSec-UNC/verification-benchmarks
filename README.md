# Hardware Security Verification Benchmarks
This repository contains security properties for the formal verification of open-source processors and SoCs. In the directory corresponding to each design is a set of properties written as SystemVerilog Assertions (SVA). Each property is documented with a description of the bug it finds and is tagged with the related CWE(s). The README in each directory describes the snapshot of the design found in that folder, including the particular commit of the design and any bugs that have been inserted.

We encourage the community to contribute new properties and pull requests are welcome!

## Getting Started
Be sure to inclue submodules when cloning the repo:

`git clone --recursive https://github.com/HWSec-UNC/verification-benchmarks.git`
or
`git clone --recursive git@github.com:HWSec-UNC/verification-benchmarks.git`

## How to Cite
Please cite our SecDev paper when using any of these properties.

@inproceedings{rogers2025hardware,
author = {Jayden Rogers and Niyaz Shakeel and Xiao Tan and Samantha Espinosa and Divya Mankani and Cade Chabra and Kaki Ryan and Cynthia Sturton},
title = {Hardware Security Benchmarks for Open-Source SystemVerilog Designs},
year = {2025},
publisher = {IEEE},
booktitle = {Proceedings of the Secure Development Conference (SecDev)}
}

A preprint version of the paper is available on arXiv: 
[Security Properties for Open-Source Hardware Designs](https://arxiv.org/abs/2412.08769)

@misc{rogers2024securitypropertiesopensourcehardware,
      title={Security Properties for Open-Source Hardware Designs}, 
      author={Jayden Rogers and Niyaz Shakeel and Divya Mankani and Samantha Espinosa and Cade Chabra and Kaki Ryan and Cynthia Sturton},
      year={2024},
      eprint={2412.08769},
      archivePrefix={arXiv},
      primaryClass={cs.CR},
      url={https://arxiv.org/abs/2412.08769 }, 
}
 
