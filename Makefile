TOOLCHAIN_DIR=/umbrella/skymizer-master-toplevel/bin
Calibrator=${TOOLCHAIN_DIR}/calibrator.cortex_m
PSim=/umbrella/onnsim/onnsim.cortex_m
INPUTFILE_PATH=/umbrella/testbench

onnsim.cortex_m : onnsim.cpp
	g++ onnsim.cpp -I /umbrella/closesrc/systemc/include/ -L /umbrella/closesrc/systemc/lib-linux64/ -o onnsim.cortex_m  -lsystemc

.PHONY : all
all : ad ic kws vww

ad:
	${Calibrator} -calibration-images ${INPUTFILE_PATH}/ad/ad01_1x640.pb ${INPUTFILE_PATH}/ad/ad01.onnx
	${PSim} ${INPUTFILE_PATH}/ad/ad01.onnx -ctable-path=ctable.json -input-data=${INPUTFILE_PATH}/ad/ad01_1x640.pb -o output_ad.bin

ic:
	${Calibrator} -calibration-images ${INPUTFILE_PATH}/ic/ic_1x3x32x32.pb ${INPUTFILE_PATH}/ic/pretrainedResnet.onnx -means=0,0,0 -scales=1,1,1
	${PSim} ${INPUTFILE_PATH}/ic/pretrainedResnet.onnx -ctable-path=ctable.json -input-data=${INPUTFILE_PATH}/ic/ic_1x3x32x32.pb -o output_ic.bin

kws:
	${Calibrator} -calibration-images ${INPUTFILE_PATH}/kws/kws01_1x1x49x10.pb ${INPUTFILE_PATH}/kws/kws_ref_model.onnx
	${PSim} ${INPUTFILE_PATH}/kws/kws_ref_model.onnx -ctable-path=ctable.json -input-data=${INPUTFILE_PATH}/kws/kws01_1x1x49x10.pb -o output_kws.bin

vww:
	${Calibrator} -calibration-images ${INPUTFILE_PATH}/vww/vw_coco2014_batch1.pb ${INPUTFILE_PATH}/vww/vww_96.onnx -means=0,0,0 -scales=255,255,255
	${PSim} ${INPUTFILE_PATH}/vww/vww_96.onnx -ctable-path=ctable.json -input-data=${INPUTFILE_PATH}/vww/vw_coco2014_batch1.pb -o output_vww.bin

.PHONY : test
test:
	@echo "Compare ad"
ifneq ($(wildcard output_ad.bin),)
ifeq ($(shell (diff -q output_ad.bin ${INPUTFILE_PATH}/ad/output.bin)),)
	@echo "Pass"
endif
endif
	@echo "Compare ic"
ifneq ($(wildcard output_ic.bin),)
ifeq ($(shell (diff -q output_ic.bin ${INPUTFILE_PATH}/ic/output.bin)),)
	@echo "Pass"
endif
endif
	@echo "Compare kws"
ifneq ($(wildcard output_kws.bin),)
ifeq ($(shell (diff -q output_kws.bin ${INPUTFILE_PATH}/kws/output.bin)),)
	@echo "Pass"
endif
endif
	@echo "Compare vww"
ifneq ($(wildcard output_vww.bin),)
ifeq ($(shell (diff -q output_vww.bin ${INPUTFILE_PATH}/vww/output.bin)),)
	@echo "Pass"
endif
endif

.PHONY : clean
clean :
	-rm *.bin onnsim.cortex_m *.json
