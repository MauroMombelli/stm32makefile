//linker script supplied
extern unsigned long _sidata;
extern unsigned long _sdata;
extern unsigned long _edata;
extern unsigned long __bss_start__;
extern unsigned long __bss_end__;
extern void (**__preinit_array_start)();
extern void (**__preinit_array_end)();
extern void (**__init_array_start)();
extern void (**__init_array_end)();

extern int main(); //user supplied
extern void SystemInit(); //stm32 lib supplied

void static_init();

inline void static_init(){
	for (void (**p)() = __preinit_array_start; p < __preinit_array_end; ++p)
		(*p)();
	
	for (void (**p)() = __init_array_start; p < __init_array_end; ++p)
		(*p)();
}

void Reset_Handler(void){
	unsigned long *source;
	unsigned long *destination;

	// BBS area must be set to zero
	for (destination = &__bss_start__; destination < &__bss_end__;){
		*(destination++) = 0;
	}

	// Copying data from Flash to RAM
	source = &_sidata;
	for (destination = &_sdata; destination < &_edata;){
		*(destination++) = *(source++);
	}

	//initialize C and C++ static and constructor
	static_init();
	
	// call initialization function into std_periph
	SystemInit();
	
	// starting main program
	main();

	while(1)
	{
		; //loop forever, but we should never be there
	}
}

void default_handler(){
	while(1);
}
