# AXIS MOVING AVERAGE
### Average input data using sliding window method

![image](docs/manual/img/AFRL.png)

---

   author: JayConvertino  
   
   date: 2023.02.01
   
   details: Provides methods of computing an average upon a input data. Sliding window method.
      
   license: MIT   
   
---

### Version
#### Current
  - V1.0.0 - initial release

#### Previous
  - none

### DOCUMENTATION
  For detailed usage information, please navigate to one of the following sources. They are the same, just in a different format.

  - [axis_moving_average.pdf](docs/manual/axis_moving_average.pdf)
  - [github page](https://johnathan-convertino-afrl.github.io/axis_moving_average/)

### Parameters

* BUS_WIDTH : DEFAULT : 1 : Width of the AXIS bus in/out.
* WEIGHT    : DEFAULT : 1 : Divisor for the average. Will only work with powers of 2 (1, 2, 4, 8, 16... etc)

### COMPONENTS
#### SRC

* axis_moving_average.v
  
#### TB

* tb_axis.v
* tb_cocotb
  
### FUSESOC

* fusesoc_info.core created.
* Simulation uses icarus to run data through the core. No verification

#### Targets

* RUN WITH: (fusesoc run --target=sim VENDER:CORE:NAME:VERSION)
  - default (for IP integration builds)
  - lint
  - sim
  - sim_cocotb
