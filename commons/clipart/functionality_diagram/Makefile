all: diagram.pdf legend.pdf


%.pdf: %.dot
	dot -Tpdf -o$@ $<
