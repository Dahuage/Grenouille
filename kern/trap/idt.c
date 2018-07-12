#include <x86.h>
#include <defs.h>
#include <idt.h>




void
init_idt(){

	struct pseudodesc *d;
	lidt(d)
}