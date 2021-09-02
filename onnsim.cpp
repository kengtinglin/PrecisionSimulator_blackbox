#include "systemc.h"
#include <iostream>
#include <unistd.h>

using namespace std;


SC_MODULE(PrecisionSimulator)
{ 
    char **cmd_;

    SC_HAS_PROCESS(PrecisionSimulator);

    PrecisionSimulator(sc_module_name name, char **cmd_) : cmd_(cmd_) {
        SC_METHOD(precision_simulator);
    }

    void precision_simulator() {
        const char *file_pth = "/umbrella/skymizer-master-toplevel/bin/precision_simulator.cortex_m";
        execvp(file_pth, cmd_);
    }
};


int sc_main(int argc, char *argv[]) {
    PrecisionSimulator precisionsimulator("precisionsimulator", argv);
    sc_start();
    return 0;
}
