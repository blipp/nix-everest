all: nixexprs.tar.xz

nixexprs.tar.xz: nixexprs
	rm nixexprs.tar.xz
	apack nixexprs.tar.xz nixexprs
