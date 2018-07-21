extern void Reset_Handler(void); //from startup.c

void default_handler(){
	while(1);
}

__attribute__((section(".isr_vector"), used)) void (*__isr_vectors[])() = {
	Reset_Handler,
	default_handler,
	default_handler,
	default_handler,
	default_handler,
	default_handler,
	default_handler,
	default_handler,
	default_handler,
	default_handler,
	default_handler,
	default_handler,
	default_handler,
	default_handler,
	default_handler,
};
