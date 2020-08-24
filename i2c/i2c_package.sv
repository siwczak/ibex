package i2c_package;
	parameter I2C_NOP = 4'b0000;
	parameter I2C_START = 4'b0001;
	parameter I2C_STOP = 4'b0010;
	parameter I2C_WRITE = 4'b0100;
	parameter I2C_READ = 4'b1000;

	parameter I2C_SLAVE_WRITE = 2'b01;
	parameter I2C_SLAVE_READ = 2'b10;
	parameter I2C_SLAVE_NOP = 2'b00;
endpackage