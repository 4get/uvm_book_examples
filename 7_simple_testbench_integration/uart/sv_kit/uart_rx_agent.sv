/*-------------------------------------------------------------------------
File name   : uart_rx_agent.sv
Title       : Rx Agent file
Project     :
Created     :
Description : build Monitor, Sequencer,Driver and connect Sequencer and driver
Notes       :  
----------------------------------------------------------------------*/
//   Copyright 1999-2010 Cadence Design Systems, Inc.
//   All Rights Reserved Worldwide
//
//   Licensed under the Apache License, Version 2.0 (the
//   "License"); you may not use this file except in
//   compliance with the License.  You may obtain a copy of
//   the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in
//   writing, software distributed under the License is
//   distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
//   CONDITIONS OF ANY KIND, either express or implied.  See
//   the License for the specific language governing
//   permissions and limitations under the License.
//----------------------------------------------------------------------

  
`ifndef UART_RX_AGENT_SV
`define UART_RX_AGENT_SV

class uart_rx_agent extends uvm_agent;

  // Active/Passive Agent configuration
  //uvm_active_passive_enum is_active = UVM_ACTIVE;
  
  // Pointer to the UART config
  uart_config cfg;

  uart_rx_monitor monitor;
  uart_rx_driver driver;     
  uart_sequencer sequencer;

  // Provides implementation of methods such as get_type_name and create
  `uvm_component_utils_begin(uart_rx_agent)
    `uvm_field_enum(uvm_active_passive_enum, is_active, UVM_DEFAULT)
    `uvm_field_object(cfg, UVM_DEFAULT | UVM_REFERENCE)
  `uvm_component_utils_end 

  // Constructor - UVM required syntax
  function new(string name = "", uvm_component parent); 
    super.new(name, parent);
  endfunction

  // Additional class methods
  extern virtual function void build_phase(uvm_phase phase);
  extern virtual function void connect_phase(uvm_phase phase);
  extern virtual function void update_config(uart_config cfg);
  
endclass : uart_rx_agent

// UVM build_phase
function void uart_rx_agent::build_phase(uvm_phase phase);
  super.build_phase(phase);
  // Configure
  if (cfg == null) begin
    if (!uvm_config_db#(uart_config)::get(this, "", "cfg", cfg))
    `uvm_warning("NOCONFIG", "Config not set for Rx agent, using default is_active field")
  end
  else is_active = cfg.is_rx_active;

  monitor = uart_rx_monitor::type_id::create("monitor",this);
  if (is_active == UVM_ACTIVE) begin
    //If UVM_ACTIVE create instances of UART Driver and Sequencer
    sequencer = uart_sequencer::type_id::create("sequencer",this);
    driver = uart_rx_driver::type_id::create("driver",this);
  end
endfunction : build_phase

// UVM connect_phase
function void uart_rx_agent::connect_phase(uvm_phase phase);
  super.connect_phase(phase);
  if (is_active == UVM_ACTIVE) begin
    // Binds the driver to the sequencer using TLM port connections
    driver.seq_item_port.connect(sequencer.seq_item_export);
  end
endfunction : connect_phase

// Assign the config to the agent's children
function void uart_rx_agent::update_config( uart_config cfg);
  monitor.cfg = cfg;
  if (is_active == UVM_ACTIVE) begin
    driver.cfg = cfg;
  end
endfunction : update_config

`endif  //UART_RX_AGENT_SV
