# A summary on the FRI low degree test. 
This survey is essentially an outcome from studying the papers [FRI](https://eccc.weizmann.ac.il/report/2017/134/), [ProximityGaps](https://eprint.iacr.org/2020/654),
[DEEP-FRI](https://eprint.iacr.org/2019/336),[Redshift](https://eprint.iacr.org/2019/1400) and the [ethSTARKdoc](https://eprint.iacr.org/2021/582).
It includes
- an overview to FRI and its soundness results, including example parameters for a plonky2-like setting;
- how FRI is turned into a commitment scheme (in the unique decoding regime), and why beyond a list-commitment model is not a good formalization if one targets tight soundness error bounds; (Although it still is a good intuitive approach.) 
- the DEEP method, with an application to AIR-like arithmetization (for illustration purpose);
- and an appendix gathering basic facts on Reed-Solomon codes, Berlekamp-Welch and Guruswami-Sudan decoding.

This version of the document is more up-to-date than [the one on IACR](https://eprint.iacr.org/2022/1216). Feedback and contributions are welcome!  
