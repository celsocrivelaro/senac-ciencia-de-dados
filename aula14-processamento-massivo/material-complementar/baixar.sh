#!/bin/sh
# Baixa os PDFs do material complementar para esta pasta e confere se cada arquivo é um PDF.
cd "$(dirname "$0")"
baixar() {
  curl -sSL -A "Mozilla/5.0" -o "$1" "$2"
  if file "$1" | grep -q PDF; then echo "ok    $1"; else echo "FALHA $1 ($2)"; rm -f "$1"; fi
}
baixar bloom-1970.pdf https://dl.acm.org/doi/pdf/10.1145/362686.362692
baixar putze-2009-bloom-bloqueado.pdf https://algo2.iti.kit.edu/documents/cacheefficientbloomfilters-jea.pdf
baixar fan-2014-filtro-de-cuco.pdf https://www.cs.cmu.edu/~dga/papers/cuckoo-conext2014.pdf
baixar cormode-2005-count-min.pdf http://dimacs.rutgers.edu/~graham/pubs/papers/cm-full.pdf
baixar gong-2018-heavykeeper.pdf https://www.usenix.org/system/files/conference/atc18/atc18-gong.pdf
baixar flajolet-2007-hyperloglog.pdf https://algo.inria.fr/flajolet/Publications/FlFuGaMe07.pdf
baixar heule-2013-hyperloglog-na-pratica.pdf https://research.google.com/pubs/archive/40671.pdf
baixar ertl-2017-estimador-hll.pdf https://arxiv.org/pdf/1702.01284
baixar broder-1997-minhash.pdf https://www.cs.princeton.edu/courses/archive/spring13/cos598C/broder97resemblance.pdf
baixar dunning-2019-t-digest.pdf https://arxiv.org/pdf/1902.04023
baixar agarwal-2013-resumos-fundiveis.pdf https://www.cs.utah.edu/~jeffp/papers/merge-summ.pdf
baixar dean-2004-mapreduce.pdf https://static.googleusercontent.com/media/research.google.com/en//archive/mapreduce-osdi04.pdf
baixar ghemawat-2003-gfs.pdf https://static.googleusercontent.com/media/research.google.com/en//archive/gfs-sosp2003.pdf
baixar zaharia-2012-rdd-spark.pdf https://www.usenix.org/system/files/conference/nsdi12/nsdi12-final138.pdf
