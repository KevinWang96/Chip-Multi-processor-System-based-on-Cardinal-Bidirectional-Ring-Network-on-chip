#!/bin/csh
# #########################################################
# EDA Tools Configurations for Viterbi Server
#    hostname: viterbi-scf2.usc.edu
# Created and maintained by: 
#     Soowang Park
#     Tools TA of the Electrical and Computer Engineering Department
# Last modified date: 08/28/2019
# #########################################################

# handy path alias by Soowang Park
alias prepend 'if (-d \!:2) if ("$\!:1" \!~ *"\!:2"*) setenv \!:1 "\!:2":${\!:1}'
alias extend  'if (-d \!:2) if ("$\!:1" \!~ *"\!:2"*) setenv \!:1 ${\!:1}:\!:2'


# #########################################################
# License Setup
# #########################################################
setenv LM_LICENSE_FILE 1800@license.usc.edu:1720@ics-lic2.usc.edu


# #########################################################
# Cadence Tools
# #########################################################
setenv SPECTRE_DEFAULTS -E
setenv CDS_Netlisting_Mode "Analog"
setenv CDS_AUTO_64BIT ALL

setenv CDSBASE /usr/local/cadence/

setenv CDS_INST_DIR $CDSBASE/IC617      # used later in cds.lib
setenv CADENCE_IC $CDSBASE/IC617        # Virtuoso
setenv CADENCE_IN $CDSBASE/INCISIVE152  # Incisive
setenv CADENCE_IV $CDSBASE/INNOVUS162   # Innovus
setenv CADENCE_MM $CDSBASE/MMSIM151     # MMSIM
setenv CADENCE_CF $CDSBASE/CONFRML161   # Conformal
setenv CADENCE_AS $CDSBASE/ASSURA41     # ASSURA
#setenv CADENCE_XC $CDSBASE/XCELIUM1704  # Xcelium

# OA path
setenv OA_HOME $CDS_INST_DIR/oa_v22.50.049

# prepend PATH for binaries
prepend PATH $CADENCE_IC/bin
prepend PATH $CADENCE_IC/tools/bin
prepend PATH $CADENCE_IC/tools/dfII/bin
prepend PATH $CADENCE_IN/tools/bin
prepend PATH $CADENCE_IV/tools/bin
prepend PATH $CADENCE_MM/tools/bin
prepend PATH $CADENCE_CF/tools.lnx86/bin
prepend PATH $CADENCE_AS/tools/bin
prepend PATH $CADENCE_AS/tools/assura/bin
#prepend PATH $CADENCE_XC/tools/bin

# NCSU FreePDK design kit
setenv CDK_DIR  /home/scf-22/ee577/design_pdk/ncsu-cdk-1.6.0.beta


# #########################################################
# Synopsys Tools
# #########################################################
setenv SYNBASE /usr/local/synopsys/

setenv SYNOPSYS_HS      $SYNBASE/HSPICE/default/hspice
setenv SYNOPSYS_DC      $SYNBASE/Design_Compiler/default	
setenv SYNOPSYS_PT      $SYNBASE/PrimeTime/default
setenv SYNOPSYS_CS      $SYNBASE/CosmosScope/default
setenv SYNOPSYS_WV	    $SYNBASE/Custom_Waveview/default
#setenv SYNOPSYS_DFT	    $SYNBASE/DFT_Compiler/default  # same as Design Compiler
setenv SYNOPSYS_TM      $SYNBASE/TetraMAX/default/TetraMAX_Standalone
setenv VCS_HOME         $SYNBASE/VCS_2016/default
setenv SYNOPSYS_STS     $SYNBASE/TCAD_Sentaurus/default

prepend PATH $SYNOPSYS_HS/bin
prepend PATH $SYNOPSYS_DC/bin
prepend PATH $SYNOPSYS_PT/bin
prepend PATH $SYNOPSYS_CS/bin
prepend PATH $SYNOPSYS_WV/bin
#prepend PATH $SYNOPSYS_DFT/bin
prepend PATH $SYNOPSYS_TM/bin
prepend PATH $VCS_HOME/bin
prepend PATH $SYNOPSYS_STS/bin

# alias
alias cscope $SYNOPSYS_CS/ai_bin/cscope
alias scope  $SYNOPSYS_CS/ai_bin/scope


# #########################################################
# Mentor Graphics Tools
# #########################################################
# Questa CDC/Formal
setenv MENTOR_QCF      /usr/local/questa_formal/linux_x86_64
prepend PATH $MENTOR_QCF/bin
