//
//  arm_syscall.c
//  cryptoVerOne
//
//  Created by Andy on 2022/10/25.
//

#include "arm_syscall.h"

void plokij() {
__asm (
           "mov x0, #31\n" // to define PT_DENY_ATTACH (31) to x0
           "mov x1, #0\n"
           "mov x2, #0\n"
           "mov x3, #0\n" //I am actually writing ptrace_ptr(PT_DENY_ATTACH, 0, 0, 0) in the above instruction set
           "mov x16, #26\n"  // set the intra-procedural to syscall #26 to invoke ‘ptrace’
           "svc #0x80\n"    // SVC generate supervisor call. Supervisor calls are normally used to request privileged operations or access to system resources from an operating system
           );
}
