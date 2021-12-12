if {[catch {

# define run engine funtion
source [file join {D:/Apps/Lattice Radiant} scripts tcl flow run_engine.tcl]
# define global variables
global para
set para(gui_mode) 1
set para(prj_dir) "C:/Users/Philip Lengyel/Documents/ES4Final/es4-guitar-hero/proj_guitar_hero"
# synthesize IPs
# synthesize VMs
# propgate constraints
file delete -force -- proj_guitar_hero_impl_1_cpe.ldc
run_engine_newmsg cpe -f "proj_guitar_hero_impl_1.cprj" "mypll.cprj" -a "iCE40UP" -o proj_guitar_hero_impl_1_cpe.ldc
# synthesize top design
file delete -force -- proj_guitar_hero_impl_1.vm proj_guitar_hero_impl_1.ldc
run_engine_newmsg synthesis -f "proj_guitar_hero_impl_1_lattice.synproj"
run_postsyn [list -a iCE40UP -p iCE40UP5K -t SG48 -sp High-Performance_1.2V -oc Industrial -top -w -o proj_guitar_hero_impl_1_syn.udb proj_guitar_hero_impl_1.vm] "C:/Users/Philip Lengyel/Documents/ES4Final/es4-guitar-hero/proj_guitar_hero/impl_1/proj_guitar_hero_impl_1.ldc"

} out]} {
   runtime_log $out
   exit 1
}
