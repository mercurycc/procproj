source=mem.v w450_tb.v

task1: tb1
task2: tb2 tb2_data
task3: tb3

task1 task2 task3:
	vvp $<

tb1: t1/w450.v
tb2: t2/w450.v
tb2: t3/w450.v

tb1 tb2 tb3: $(source)
	iverilog -s w450_tb -o $@ $^

tb2_data:
# Build and link sortArray.data

clean:
	rm -f a.out tb1 tb2 tb3
# Add dump data
