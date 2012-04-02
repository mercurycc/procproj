source=w450_tb.v

all: task1 task2 task3
task1: tb1
task2: tb2
task3: tb3

task1 task2 task3:
	@echo Simulating $@
	@vvp $<

tb1: t1/w450.v t1/mem.v
tb2: t1/w450.v t2/mem.v  # Use task 1 w450.v
tb3: t3/w450.v t3/mem.v

tb1 tb2 tb3: $(source)
	@echo Compiling $@
	@iverilog -s w450_tb -o $@ $^

.PHONY: clean

clean:
	rm -f a.out tb1 tb2 tb3
