# Simple Proccessor Implementation
### Design Description
A processor executes operations specified in the form of instructions. In this project, a string of instructions will be given. What I've done is to decode these instructions and execute.

The following is the basic required instruction format: 
(similar to MIPS)

`R-type opcode (6) rs (5) rt (5) rd (5) shamt (5) funct (6)`

`I-type opcode (6) rs (5) rt (5) immediate (16)`

The following is the required instruction set of this design : 
![image](https://user-images.githubusercontent.com/71891722/212061838-155d86a0-01da-4e76-8a42-72477eff2079.png)
![image](https://user-images.githubusercontent.com/71891722/212061898-92af208e-5424-41fb-838b-abf68b4bf5bc.png)


### Design Inputs and Outputs
Input Signals : 
![image](https://user-images.githubusercontent.com/71891722/212061401-e40b9505-b70d-4528-b2d7-5f69318de93c.png)

Output Signals : 
![image](https://user-images.githubusercontent.com/71891722/212061537-6ec64391-16ff-4e24-8452-111c2c814cb0.png)

### Specification
1. Top module name: SP (Design file name: SP.v)
2. It is asynchronous and active-low reset. If uses synchronous reset in design may fail to reset signals.
3. The reset signal (rst_n) would be given only once at the beginning of simulation.
4. inst_addr, out_valid and register file r should be reset after the reset signal is asserted.
5. out_valid should not be raised when in_valid is high for non-pipline design. 
6. The out_valid should be raised within 10 cycles after in_valid raised.
7. Next instruction will be given in the next cycle after out_valid is raised.
8. Pattern will check the register file r result and inst_addr for each instruction at clock negetive edge when out_valid is high.
9. Pattern will check the final result of mem.v.
10. Released and demo pattern will not cause overflow

### Additional specification for pipelined design
11. Use the same instruction.txt and mem.txt file as non-pipeline design.
12. Modify the pattern name in TESTBED.v to use pipeline version pattern.
13. No need to consider branch prediction.The correct inst_addr should be given by design after beq/bnq instructions fetehed.
14. No need to consider data hazards. data dependency or load-use will be separated by at least two instructions to avoid data hazards in pattern.
15. Once out_valid raised, it should be kept high until simulation end.
16. Pattern will check the sequence inst_addr.

### Usage and Notification :
* I design the processor in pipeline structure
* For wave simulation, I use ModelSim to compile and debug
* To successfully compiled, TESTBED.v, PATTERN.v, MEM.v and SP.v are needed. However, only SP.v is provided due to copyright issues.
