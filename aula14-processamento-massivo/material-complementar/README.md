# Material complementar — Aula 14: Processamento Massivo

Artigos originais das estruturas e dos sistemas tratados na aula, na ordem das notas. Todos os links apontam para cópias de acesso livre (arXiv, páginas dos autores, das instituições, da USENIX ou do Google Research). O script `baixar.sh` baixa os PDFs para esta pasta.

| Assunto | Referência | PDF |
|---|---|---|
| Filtro de Bloom | BLOOM, B. H. Space/time trade-offs in hash coding with allowable errors. *Communications of the ACM*, v. 13, n. 7, p. 422–426, 1970. | https://dl.acm.org/doi/pdf/10.1145/362686.362692 |
| Filtro de Bloom bloqueado | PUTZE, F.; SANDERS, P.; SINGLER, J. Cache-, hash-, and space-efficient Bloom filters. *ACM Journal of Experimental Algorithmics*, v. 14, 2009. | https://algo2.iti.kit.edu/documents/cacheefficientbloomfilters-jea.pdf |
| Filtro de cuco | FAN, B.; ANDERSEN, D. G.; KAMINSKY, M.; MITZENMACHER, M. D. Cuckoo filter: practically better than Bloom. In: *CoNEXT*, 2014. | https://www.cs.cmu.edu/~dga/papers/cuckoo-conext2014.pdf |
| *Count-min sketch* | CORMODE, G.; MUTHUKRISHNAN, S. An improved data stream summary: the count-min sketch and its applications. *Journal of Algorithms*, v. 55, n. 1, p. 58–75, 2005. | http://dimacs.rutgers.edu/~graham/pubs/papers/cm-full.pdf |
| *Top-k*: *Space-Saving* | METWALLY, A.; AGRAWAL, D.; EL ABBADI, A. Efficient computation of frequent and top-k elements in data streams. In: *ICDT*, 2005. | página da UCSB (relatório técnico 2005-23) |
| *Top-k*: *HeavyKeeper* | GONG, J. et al. HeavyKeeper: an accurate algorithm for finding top-k elephant flows. In: *USENIX ATC*, 2018. | https://www.usenix.org/system/files/conference/atc18/atc18-gong.pdf |
| HyperLogLog | FLAJOLET, P.; FUSY, É.; GANDOUET, O.; MEUNIER, F. HyperLogLog: the analysis of a near-optimal cardinality estimation algorithm. In: *AofA*, 2007. | https://algo.inria.fr/flajolet/Publications/FlFuGaMe07.pdf |
| HyperLogLog++ | HEULE, S.; NUNKESSER, M.; HALL, A. HyperLogLog in practice. In: *EDBT*, 2013. | https://research.google.com/pubs/archive/40671.pdf |
| Estimador de Ertl | ERTL, O. New cardinality estimation algorithms for HyperLogLog sketches. arXiv:1702.01284, 2017. | https://arxiv.org/pdf/1702.01284 |
| MinHash | BRODER, A. Z. On the resemblance and containment of documents. In: *Compression and Complexity of Sequences*, 1997. | https://www.cs.princeton.edu/courses/archive/spring13/cos598C/broder97resemblance.pdf |
| *t-digest* | DUNNING, T.; ERTL, O. Computing extremely accurate quantiles using t-digests. arXiv:1902.04023, 2019. | https://arxiv.org/pdf/1902.04023 |
| Resumos fundíveis | AGARWAL, P. K. et al. Mergeable summaries. *ACM Transactions on Database Systems*, v. 38, n. 4, 2013. | https://www.cs.utah.edu/~jeffp/papers/merge-summ.pdf |
| MapReduce | DEAN, J.; GHEMAWAT, S. MapReduce: simplified data processing on large clusters. In: *OSDI*, 2004. | https://static.googleusercontent.com/media/research.google.com/en//archive/mapreduce-osdi04.pdf |
| GFS | GHEMAWAT, S.; GOBIOFF, H.; LEUNG, S.-T. The Google file system. In: *SOSP*, 2003. | https://static.googleusercontent.com/media/research.google.com/en//archive/gfs-sosp2003.pdf |
| Spark (RDD) | ZAHARIA, M. et al. Resilient distributed datasets: a fault-tolerant abstraction for in-memory cluster computing. In: *NSDI*, 2012. | https://www.usenix.org/system/files/conference/nsdi12/nsdi12-final138.pdf |
| Livro | LESKOVEC, J.; RAJARAMAN, A.; ULLMAN, J. D. *Mining of Massive Datasets*. 3. ed. Cambridge University Press, 2020. Capítulos 2 (MapReduce), 3 (MinHash e LSH) e 4 (fluxos de dados). | http://www.mmds.org/ |
