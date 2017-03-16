#!/bin/bash

# Obtain the directory where this script is located
old_dir=`pwd`; cd `dirname $0`; self=`pwd`; cd ${old_dir}; old_dir=

# ---------------------------------------------------------------------------
# Imports

ocroot="${self}/.."
source ${ocroot}/ciaotool_modules/compat.sh
source ${ocroot}/ciaotool_modules/config.sh
source ${ocroot}/ciaotool_modules/messages.sh
source ${ocroot}/ciaotool_modules/compare_files.sh
source ${ocroot}/ciaotool_modules/archdump.sh

# ---------------------------------------------------------------------------

action=$1
module_name=$2

# TODO: improve documentation
help() {
    cat <<EOF
Usage: `basename $0` ACTION module_name

Where ACTION is one of:

    compareemu
    briefcompareemu
    saveemu
    runexec
    [mtsys-]checkmod[-SYS]
    [mtsys-]comparemod[-SYS]
    [mtsys-]briefcomparemod[-SYS]
    [mtsys-]savemod[-SYS]
    checkexec
    compareexec
    briefcompareexec
    saveexec
    evalexec
    [mtsys-]evalmod[-SYS]

The prefix 'mtsys-' is optional. When provided, a system must be
provided as suffix.

This program:

  - build an executable (checkexec) or module (checkmod) and compares
    the resulting bytecode and C code, indicating the differences
    w.r.t. a previously saved result

  - builds an executable and executes it (runexec) 

  - builds an executable (evalexec) or module (evalmod) and evaluates
    is performance

  - the user can choose between saving the results for executables
    (saveexec) or modules (savemod)

EOF
    exit 1
}

# ---------------------------------------------------------------------------

ensure_exists() {
    local prg
    prg=$1
    if [ -r ${prg}.pl ] ; then
	true
    else
	echo "Program '${prg}' not found, aborting."
	exit -1
    fi
}

# ---------------------------------------------------------------------------

# Path of the output file for a benchmark (exec, compilation output, etc.)
get_prgout() {
    local prg
    prg=$1
    echo "${regression_dir}/out/${prg}"
}

# ---------------------------------------------------------------------------

tracefile="/tmp/ciao__trace.txt"
clean_trace() {
    rm -f ${tracefile}
}

dump_trace() {
    test -r ${tracefile} && cat ${tracefile} || true
}

# ---------------------------------------------------------------------------

compareexec() {
    local mode
    local prg
    local prgout
    mode=$1
    prg=$2
    ensure_exists ${prg}
    ensure_regression_dir
    prgout=`get_prgout ${prg}`
    # TODO: missing C code diff, etc.
    difffiles "exec ${prg}: generated bytecode" ${prgout}.disasm ${prgout}.disasm-orig ${mode}
}

checkexec() {
    local prg
    local prgout
    prg=$1
    ensure_exists ${prg}
    ensure_regression_dir
    prgout=`get_prgout ${prg}`
    rm -f ${prgout}.disasm
    # TODO: clean the user cache to ensure that the file is recompiled!
    echo "Compiling exec ${prg}"
    ${ocroot}/ciaotool comp --dynexec ${prgout} ${prg} || return 1
    ciaodump --file compile__emu ${prgout} > ${prgout}.disasm
    compareexec brief ${prg}
}

runexec() {
    local prg
    local prgout
    prg=$1
    ensure_exists ${prg}
    ensure_regression_dir
    prgout=`get_prgout ${prg}`
    echo "Running exec ${prg}"
    ${ocroot}/ciaotool comp --dynexec ${prgout} ${prg} && ${prgout}
}

# ---------------------------------------------------------------------------

EMU_CFILES="basiccontrol.native.c"
EMU_HFILES="basiccontrol.native.h"
#EMU_SFILES="basiccontrol.native engine__gc internals arithmetic"
#EMU_OFILES="basiccontrol.native engine__gc internals arithmetic"
EMU_SFILES="basiccontrol.native arithmetic atomic_basic attributes concurrency dynlink engine__alloc engine__bignum engine__ciao_prolog engine__debug engine__float_tostr engine__gc engine__interrupt engine__main engine__own_mmap engine__own_malloc engine__profile engine__registers engine__resources engine__threads internals io_basic prolog_sys ql_inout rt_exp streams_basic system system_info term_basic term_compare terms_check term_typing timing"
EMU_OFILES="basiccontrol.native arithmetic atomic_basic attributes concurrency dynlink engine__alloc engine__bignum engine__ciao_prolog engine__debug engine__float_tostr engine__gc engine__interrupt engine__main engine__own_mmap engine__own_malloc engine__profile engine__registers engine__resources engine__threads internals io_basic prolog_sys ql_inout rt_exp streams_basic system system_info term_basic term_compare terms_check term_typing timing"

compc_exe="${tmpcomp_dir}/compc"

bringemu() {
    ensure_regression_dir
    pushd "${regression_dir}/emucomp" > /dev/null
    ${ocroot}/ciaotool comp --recursive-deps ${ocroot}/apps/comp > curr/all_modules
    EMU_BCFILES=`cat curr/all_modules`
    for i in $EMU_BCFILES; do
	j=`escape_mod_name ${i}`
	ciaodump --disasm ${i} > curr/${j}.emu
    done
    for i in $EMU_CFILES; do
	cp ${compc_exe}.car/c/engine/${i} curr/${i}
    done
    for i in $EMU_HFILES; do
	cp ${compc_exe}.car/c/engine/${i} curr/${i}
    done
    for i in $EMU_SFILES; do
	cp ${compc_exe}.car/o/${i}.s curr/${i}.s
    done
    for i in $EMU_OFILES; do
	archdump ${compc_exe}.car/o/${i}.o > curr/${i}.o.s
    done
    popd > /dev/null
}

escape_mod_name() {
    echo $1 | tr '/' '.'
}

compareemu() {
    local mode
    local ret
    mode=${1}
    bringemu
    ret=0
    ensure_regression_dir
    pushd "${regression_dir}/emucomp" > /dev/null
    difffiles "list of modules" curr/all_modules prev/all_modules-0 ${mode} || ret=1
    EMU_BCFILES=`cat curr/all_modules`
    for i in $EMU_BCFILES; do
	j=`escape_mod_name ${i}`
	difffiles "bytecode for ${i}" curr/${j}.emu prev/${j}.emu-0 ${mode} || ret=1
    done
    for i in $EMU_CFILES; do
	difffiles "generated C code ${i}" curr/${i} prev/${i}-0 ${mode} || ret=1
    done
    for i in $EMU_HFILES; do
	difffiles "generated C header code ${i}" curr/${i} prev/${i}-0 ${mode} || ret=1
    done
    for i in $EMU_SFILES; do
	difffiles "gcc assembled code ${i}.s" curr/${i}.s prev/${i}.s-0 ${mode} || ret=1
    done
    for i in $EMU_OFILES; do
	difffiles "disassembled gcc code ${i}.o.s" curr/${i}.o.s prev/${i}.o.s-0 ${mode} || ret=1
    done
    popd > /dev/null
    return ${ret}
}

saveemu() {
    bringemu
    ensure_regression_dir
    pushd "${regression_dir}/emucomp" > /dev/null
    cp curr/all_modules prev/all_modules-0
    EMU_BCFILES=`cat curr/all_modules`
    for i in $EMU_BCFILES; do
	j=`escape_mod_name ${i}`
	cp curr/${j}.emu prev/${j}.emu-0
    done
    for i in $EMU_CFILES; do
	cp curr/${i} prev/${i}-0
    done
    for i in $EMU_HFILES; do
	cp curr/${i} prev/${i}-0
    done
    for i in $EMU_SFILES; do
	cp curr/${i}.s prev/${i}.s-0
    done
    for i in $EMU_OFILES; do
	cp curr/${i}.o.s prev/${i}.o.s-0
    done
    popd > /dev/null
}

# ---------------------------------------------------------------------------

comparemod() {
    local mode
    local prg
    local prgout
    local ret
    mode=$1
    prg=$2
    ret=0
    ensure_exists ${prg}
    ensure_regression_dir
    prgout=`get_prgout ${prg}`
    difffiles "module ${prg}: analysis dump" ${prgout}.dump.txt ${prgout}.dump.orig.txt ${mode} || ret=1
    difffiles "module ${prg}: generated bytecode" ${prgout}.emu.txt ${prgout}.emu.orig.txt ${mode} || ret=1
    difffiles "module ${prg}: generated C code" ${prgout}.native.txt ${prgout}.native.orig.txt ${mode} || ret=1
    difffiles "module ${prg}: generated C header code" ${prgout}.native_h.txt ${prgout}.native_h.orig.txt ${mode} || ret=1
    difffiles "module ${prg}: generated gcc assembler code" ${prgout}.s.txt ${prgout}.s.orig.txt ${mode} || ret=1
    difffiles "module ${prg}: disassembled gcc code" ${prgout}.o.s.txt ${prgout}.o.s.orig.txt ${mode} || ret=1
    return ${ret}
}

checkmod() {
    local prg
    local prgout
    prg=$1
    ensure_exists ${prg}
    ensure_regression_dir
    prgout=`get_prgout ${prg}`
    # TODO: do not touch, clean the user cache!
    touch ${prg}.pl && \
        echo "Compiling module ${prg}" && \
#	CIAORTOPTS="-proft" ${ocroot}/ciaotool comp --do compile ${prg} && \
	${ocroot}/ciaotool comp --comp-stats --do compile ${prg} && \
        echo "Generating native code (if required) for module ${prg}" && \
	${ocroot}/ciaotool comp --do archcompile ${prg} || return 1    
    ciaodump --module compile__dump ${prg} > ${prgout}.dump.txt
    ciaodump --module compile__emu ${prg} > ${prgout}.emu.txt
    ciaodump --module compile__c ${prg} > ${prgout}.native.txt
    ciaodump --module compile__h ${prg} > ${prgout}.native_h.txt
    ciaodump --module archcompile__s ${prg} > ${prgout}.s.txt
    ciaodump --module archcompile__o ${prg} > ${prgout}.o.s.txt
    comparemod brief ${prg}
}

# ---------------------------------------------------------------------------

VERNAME="testing"
versuf="_${VERNAME}"

# TODO: do not call main/0, but an entry for performance evaluation
evalmod() {
    local prg
    local prgout
    local outfile
    prg=$1
    ensure_regression_dir
    prgout=`get_prgout ${prg}`
    outfile="/tmp/ciao__out.txt"
    rm -f ${outfile}
    echo "test: ${prg}"
    clean_trace
#    echo "use_module(${prg}). main." | ${ocroot}/ciaotool run-testing ${cache_dir}/bin/ciao-toplevel${sufver} 2>/dev/null
    echo "use_module(${prg}). main." | ${cache_dir}/bin/ciao-toplevel 2>/dev/null
    dump_trace
#    ciaodump${versuf} --module dectok ${prg} 2>/dev/null | head -1 # Print bytecode size
}

# ---------------------------------------------------------------------------

# TODO: improve (add an argument that distiguish between performance run and test case run; do the same for modules)
evalexec() {
    local prg
    local prgout
    prg=$1
    ensure_regression_dir
    prgout=`get_prgout ${prg}`
#    ${ocroot}/ciaotool comp-testing --dynexec ${prgout} ${prg}
    ${ocroot}/ciaotool comp --dynexec ${prgout} ${prg}
    clean_trace
#    ${ocroot}/ciaotool run-testing ./${prg}
    ./${prgout}
    dump_trace
    ciaodump --file dectok ${prgout} 2>/dev/null | head -1 # Print bytecode size
}

# ---------------------------------------------------------------------------
# (multisystem tests)

# Output directory for tests results and temporary files
mtsys_outdir=${ocroot}/testsuite/multisystemtests/out
mkdir -p ${mtsys_outdir}

# TODO: size of objects is not accurate! (for some systems, it only
# measures size on disk, or not all memory sections are measured)

function mtsys_checkmod() {
    system=$1
    pl=$2
    mod=$(basename ${pl} .pl)
    pushd ${ocroot}/testsuite/tests/${mod}/ > /dev/null
    temp=temp_${mod}_${system}
    case ${system} in
	ciao2 ) # optimcomp without compilation to native code
	    cpp -DSYSTEM=ciao2 -DCIAO2 -DOPT_MASK=0 -C -P < ${mod}.pl > ${mtsys_outdir}/${temp}.pl
	    ;;
	ciao3 )
	    cpp -DSYSTEM=ciao3 -DCIAO3 -DOPT_MASK=63 -C -P < ${mod}.pl > ${mtsys_outdir}/${temp}.pl
	    ;;
    esac
    popd > /dev/null
    pushd ${mtsys_outdir} > /dev/null
    ${ocroot}/ciaotool bench checkmod ${temp}
    popd > /dev/null
}

function mtsys_comparemod() {
    system=$1
    pl=$2
    mod=$(basename ${pl} .pl)
    pushd ${ocroot}/testsuite/tests/${mod}/ > /dev/null
    temp=temp_${mod}_${system}
    popd > /dev/null
    pushd ${mtsys_outdir} > /dev/null
    ${ocroot}/ciaotool bench comparemod ${temp}
    popd > /dev/null
}

function mtsys_briefcomparemod() {
    system=$1
    pl=$2
    mod=$(basename ${pl} .pl)
    pushd ${ocroot}/testsuite/tests/${mod}/ > /dev/null
    temp=temp_${mod}_${system}
    popd > /dev/null
    pushd ${mtsys_outdir} > /dev/null
    ${ocroot}/ciaotool bench briefcomparemod ${temp}
    popd > /dev/null
}

function mtsys_savemod() {
    system=$1
    pl=$2
    mod=$(basename ${pl} .pl)
    pushd ${ocroot}/testsuite/tests/${mod}/ > /dev/null
    temp=temp_${mod}_${system}
    popd > /dev/null
    pushd ${mtsys_outdir} > /dev/null
    ${ocroot}/ciaotool bench savemod ${temp}
    popd > /dev/null
}

function mtsys_evalmod() {
    system=$1
    pl=$2
    mod=$(basename ${pl} .pl)
    pushd ${ocroot}/testsuite/tests/${mod}/ > /dev/null
    temp=temp_${mod}_${system}

#    echo "test: ${mod}"

    case ${system} in
	ciao ) # default ciaoc
	    rm -f ${mtsys_outdir}/${temp}.itf
	    rm -f ${mtsys_outdir}/${temp}.po
	    cpp -DSYSTEM=ciao -DCIAO -DOPT_MASK=0 -C -P < ${mod}.pl > ${mtsys_outdir}/${temp}.pl
	    ciaoc ${mtsys_outdir}/${temp}.pl
	    ${mtsys_outdir}/${temp}
	    sizefield "${mtsys_outdir}/${temp}.po"
	    ;;
	ciao_1_6 ) # ciao 1.6
	    rm -f ${mtsys_outdir}/${temp}.itf
	    rm -f ${mtsys_outdir}/${temp}.po
#	    CIAO_1_6_DIR="/Users/jfran/Documents/svn/ciao-1.6.0/ciaoc"
	    cpp -DSYSTEM=ciao_1_6 -DCIAO -DOPT_MASK=0 -C -P < ${mod}.pl > ${mtsys_outdir}/${temp}.pl
#	    ${CIAO_1_6_DIR}/ciaoc ${mtsys_outdir}/${temp}.pl
	    ciaoc-1.6 ${mtsys_outdir}/${temp}.pl
	    ${mtsys_outdir}/${temp}
	    sizefield "${mtsys_outdir}/${temp}.po"
	    ;;
	ciao2 ) # optimcomp without compilation to native code
	    cpp -DSYSTEM=ciao2 -DCIAO2 -DOPT_MASK=0 -C -P < ${mod}.pl > ${mtsys_outdir}/${temp}.pl
            # Using the toplevel
	    pushd ${mtsys_outdir} > /dev/null
	    ${ocroot}/ciaotool bench evalmod ${temp} || return 1
	    popd > /dev/null
            # Using executables
#	    ${ocroot}/ciaotool comp --bootstrap ${mtsys_outdir}/${temp} ${mtsys_outdir}/${temp} || return 1
#	    ${mtsys_outdir}/${temp}.car/clean
#	    ${mtsys_outdir}/${temp}.car/run
#	    ciaodump --module dectok ${mtsys_outdir}/${temp} 2>/dev/null | head -1 # Print bytecode size
	    ;;
	ciao3 ) # optimcomp with compilation to native code
	    cpp -DSYSTEM=ciao3 -DCIAO3 -DOPT_MASK=63 -C -P < ${mod}.pl > ${mtsys_outdir}/${temp}.pl
            # Using the toplevel
#	    pushd ${mtsys_outdir} > /dev/null
#	    ${ocroot}/ciaotool bench evalmod ${temp} || return 1
#	    popd > /dev/null
            # Using dynamic executables
            # TODO: does not work because the C code is not included
#	    ${ocroot}/ciaotool comp --dynexec ${mtsys_outdir}/${temp} ${mtsys_outdir}/${temp} || return 1
#	    ${mtsys_outdir}/${temp}
            # Check source
#	    pushd ${mtsys_outdir} > /dev/null
#	    ${ocroot}/ciaotool bench checkmod ${temp}
#	    popd > /dev/null
            # Using executables
	    ${ocroot}/ciaotool comp --bootstrap ${mtsys_outdir}/${temp} ${mtsys_outdir}/${temp} || return 1
	    ${mtsys_outdir}/${temp}.car/clean
	    #todo: adding those options were good for the language-shootout, but the speedup was not impressive with ptoc: CIAOCCOPTS="-O3 -march=pentium4 -mfpmath=sse -msse2" 
	    ${mtsys_outdir}/${temp}.car/run
	    ciaodump --module dectok ${mtsys_outdir}/${temp} 2>/dev/null | head -1 # Print bytecode size
	    ;;
	sicstus )
	    cpp -DSYSTEM=sicstus -DSICSTUS -DOPT_MASK=0 -C -P < ${mod}.pl > ${mtsys_outdir}/${temp}.pl
	    # TODO: missing get size of object
	    echo > ${mtsys_outdir}/${temp}.object
	    echo -ne "use_module('${mtsys_outdir}/${temp}.pl'), main, halt.\n" | sicstus-3.8.6
	    sizefield "${mtsys_outdir}/${temp}.object"
	    ;;
	yap )
	    cpp -DSYSTEM=yap -DYAP -DOPT_MASK=0 -C -P < ${mod}.pl > ${mtsys_outdir}/${temp}.pl
	    # TODO: missing get size of object
	    echo > ${mtsys_outdir}/${temp}.object
	    echo -ne "use_module('${mtsys_outdir}/${temp}.pl'), main, halt.\n" | yap
	    sizefield "${mtsys_outdir}/${temp}.object"
	    ;;
	hprolog )
	    cpp -DSYSTEM=hprolog -DHPROLOG -DOPT_MASK=0 -C -P < ${mod}.pl > ${mtsys_outdir}/${temp}.pl
	    # TODO: missing get size of object
	    echo > ${mtsys_outdir}/${temp}.object
	    echo -ne "use_module('${mtsys_outdir}/${temp}.pl'), temp:main, halt.\n" | hProlog
	    sizefield "${mtsys_outdir}/${temp}.object"
	    ;;
	swiprolog )
	    cpp -DSYSTEM=swiprolog -DSWIPROLOG -DOPT_MASK=0 -C -P < ${mod}.pl > ${mtsys_outdir}/${temp}.pl
	    # TODO: missing get size of object
	    echo > ${mtsys_outdir}/${temp}.object
	    echo -ne "use_module('${mtsys_outdir}/${temp}.pl'), temp:main, halt.\n" | swipl -q
	    sizefield "${mtsys_outdir}/${temp}.object"
	    ;;
	gprolog )
	    echo ":- initialization(main)." > ${mtsys_outdir}/${temp}.pl
	    cpp -DSYSTEM=gprolog -DGPROLOG -DOPT_MASK=0 -C -P < ${mod}.pl >> ${mtsys_outdir}/${temp}.pl
	    gplc --no-top-level ${mtsys_outdir}/${temp}.pl -o ${mtsys_outdir}/${temp}
	    # TODO: missing get size of object
	    echo > ${mtsys_outdir}/${temp}.object
	    ${mtsys_outdir}/${temp}
	    sizefield "${mtsys_outdir}/${temp}.object"
	    ;;
	wamcc )
	    echo ":- main." > ${mtsys_outdir}/${temp}.pl
	    echo ":- main, halt." >> ${mtsys_outdir}/${temp}.pl
	    cpp -DSYSTEM=wamcc -DWAMCC -DOPT_MASK=0 -C -P < ${mod}.pl >> ${mtsys_outdir}/${temp}.pl
	    wamcc -c ${mtsys_outdir}/${temp}.pl
	    w_gcc -c ${mtsys_outdir}/${temp}.c
	    w_gcc -o ${mtsys_outdir}/${temp} ${mtsys_outdir}/${temp}.o -lwamcc
	    # TODO: missing get size of object
	    echo > ${mtsys_outdir}/${temp}.object
	    mv ${mtsys_outdir}/${temp}.o ${mtsys_outdir}/${temp}.object
	    ${mtsys_outdir}/${temp}
	    sizefield "${mtsys_outdir}/${temp}.object"
	    ;;
	mercury )
	    cpp -DMODULE=${mod} -DSYSTEM=mercury -DMERCURY -DOPT_MASK=0 -C -P < ${mod}.pl > ${mtsys_outdir}/${temp}.m
	    PATH=$PATH:/usr/local/mercury-0.11.0/bin mmc -E -O9 ${mtsys_outdir}/${temp}.m -o ${mtsys_outdir}/${temp}
	    ${mtsys_outdir}/${temp}
	    sizefield "${mtsys_outdir}/${temp}.o"
	    ;;
	mercury-hlc )
	    cpp -DMODULE=${mod} -DSYSTEM=mercury -DMERCURY -DOPT_MASK=0 -C -P < ${mod}.pl > ${mtsys_outdir}/${temp}.m
	    PATH=$PATH:/usr/local/mercury-0.11.0/bin mmc --grade hlc -E -O9 ${mtsys_outdir}/${temp}.m -o ${mtsys_outdir}/${temp}
	    ${mtsys_outdir}/${temp}
	    sizefield "${mtsys_outdir}/${temp}.o"
	    ;;
	*)
	    echo "Unknown system: ${system}"
    esac
    popd > /dev/null
}

function sizefield() {
#    echo "object_size($1, `size_of_file $2`)."
    echo "object_size: `size_of_file $1`"
}

# ---------------------------------------------------------------------------

eval `${ocroot}/ciaotool bash-env`

# TODO: do not use save-no-ask by default, add parameters to save different
# versions (e.g. for different architectures, absmach options, etc.)
SAVECMD="save-no-ask"
#SAVECMD="save"

case ${action} in
    compareemu) compareemu full ;;
    briefcompareemu) compareemu brief ;;
    saveemu) compareemu ${SAVECMD} ;;
    runexec) runexec ${module_name} ;;
    checkmod) checkmod ${module_name} ;;
    comparemod) comparemod full ${module_name} ;;
    briefcomparemod) comparemod brief ${module_name} ;;
    savemod) comparemod ${SAVECMD} ${module_name} ;;
    checkexec) checkexec ${module_name} ;;
    compareexec) compareexec full ${module_name} ;;
    briefcompareexec) compareexec brief ${module_name} ;;
    saveexec) compareexec ${SAVECMD} ${module_name} ;;
    evalexec) evalexec ${module_name} ;;
    evalmod) evalmod ${module_name} ;;
    #    
    mtsys-evalmod-yap) mtsys_evalmod yap ${module_name} ;;
    mtsys-evalmod-hprolog) mtsys_evalmod hprolog ${module_name} ;;
    mtsys-evalmod-sicstus) mtsys_evalmod sicstus ${module_name} ;;
    mtsys-evalmod-swiprolog) mtsys_evalmod swiprolog ${module_name} ;;
    mtsys-evalmod-ciao) mtsys_evalmod ciao ${module_name} ;;
    mtsys-evalmod-ciao_1_6) mtsys_evalmod ciao_1_6 ${module_name} ;;
    mtsys-evalmod-ciao2) mtsys_evalmod ciao2 ${module_name} ;;
    mtsys-evalmod-ciao3) mtsys_evalmod ciao3 ${module_name} ;;
    mtsys-checkmod-ciao2) mtsys_checkmod ciao2 ${module_name} ;;
    mtsys-checkmod-ciao3) mtsys_checkmod ciao3 ${module_name} ;;
    mtsys-savemod-ciao2) mtsys_savemod ciao2 ${module_name} ;;
    mtsys-savemod-ciao3) mtsys_savemod ciao3 ${module_name} ;;
    mtsys-comparemod-ciao2) mtsys_comparemod ciao2 ${module_name} ;;
    mtsys-comparemod-ciao3) mtsys_comparemod ciao3 ${module_name} ;;
    mtsys-briefcomparemod-ciao2) mtsys_briefcomparemod ciao2 ${module_name} ;;
    mtsys-briefcomparemod-ciao3) mtsys_briefcomparemod ciao3 ${module_name} ;;
    *) help
esac

