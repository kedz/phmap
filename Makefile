X10C=${X10_HOME}/bin/x10c++
FLAGS=-O -NO_CHECKS
#FLAGS=
UNI1=crk2130
UNI2=pwn2107

Hash: Main.x10 Hash.x10 ConList.x10
	$(X10C) $(FLAGS) -o $@ $^

test: Hash
	./Hash

clean:
	rm -f Hash *.h *.out *.err *.log *~ *.cc
