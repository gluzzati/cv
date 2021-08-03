#!/bin/bash

TEXMF_TREE=$(kpsewhich --var-value TEXMFLOCAL)
unzip roboto.tds.zip -d ${TEXMF_TREE}
mktexlsr
updmap-sys --force --enable Map=roboto.map
