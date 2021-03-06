# Copyright (C) 2001-2016 Quantum ESPRESSO group
# 
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License. See the file `License' in the root directory
# of the present distribution.

# QE Bundle v1.0, custom for Schrödinger 

include make.inc

default :
	@echo 'to install Quantum ESPRESSO, type at the shell prompt:'
	@echo '  ./configure [--prefix=]'
	@echo '  make [-j] target'
	@echo ' '
	@echo 'where target identifies one or multiple CORE PACKAGES:'
	@echo '  pw           basic code for scf, structure optimization, MD'
	@echo '  pwcond       ballistic conductance'
	@echo '  neb          code for Nudged Elastic Band method'
	@echo '  pp           postprocessing programs'
	@echo '  pwall        same as "make pw pp pwcond neb"'
	@echo '  ld1          utilities for pseudopotential generation'
	@echo '  upf          utilities for pseudopotential conversion'
	@echo '  all          same as "make pwall ld1 upf"'
	@echo ' '
	@echo 'where target is one of the following suite operation:'
	@echo '  doc          build documentation'
	@echo '  links        create links to all executables in bin/'
	@echo '  tar          create a tarball of the source tree'
	@echo '  clean        remove executables and objects'
	@echo '  veryclean    remove files produced by "configure" as well'
	@echo '  distclean    revert distribution to the original status'

###########################################################
# Main targets
###########################################################

# The syntax "( cd PW ; $(MAKE) TLDEPS= all || exit 1)" below
# guarantees that error code 1 is returned in case of error and make stops
# If "|| exit 1" is not present, the error code from make in subdirectories
# is not returned and make goes on even if compilation has failed

pw : bindir libfft libla mods liblapack libs libiotk 
	if test -d PW ; then \
	( cd PW ; $(MAKE) TLDEPS= all || exit 1) ; fi

pw-lib : bindir libfft libla mods liblapack libs libiotk
	if test -d PW ; then \
	( cd PW ; $(MAKE) TLDEPS= pw-lib || exit 1) ; fi

### This target is not supported in this version
#cp : bindir libfft libla mods liblapack libs libiotk
#	if test -d CPV ; then \
#	( cd CPV ; $(MAKE) TLDEPS= all || exit 1) ; fi

### This target is not supported in this version
#ph : bindir libfft libla mods libs pw lrmods
#	if test -d PHonon; then \
#	(cd PHonon; $(MAKE) all || exit 1) ; fi

neb : bindir libfft libla mods libs pw
	if test -d NEB; then \
  (cd NEB; $(MAKE) all || exit 1) ; fi

### This target is not supported in this version
#tddfpt : bindir libfft libla mods libs pw
#	if test -d TDDFPT; then \
#	(cd TDDFPT; $(MAKE) all || exit 1) ; fi

pp : bindir libfft libla mods libs pw
	if test -d PP ; then \
	( cd PP ; $(MAKE) TLDEPS= all || exit 1 ) ; fi

pwcond : bindir libfft libla mods libs pw pp
	if test -d PWCOND ; then \
	( cd PWCOND ; $(MAKE) TLDEPS= all || exit 1 ) ; fi

### This target is not supported in this version
#acfdt : bindir libfft libla mods libs pw ph
#	if test -d ACFDT ; then \
#	( cd ACFDT ; $(MAKE) TLDEPS= all || exit 1 ) ; fi

# target still present for backward compatibility
gww:
	@echo '"make gww" is obsolete, use "make gwl" instead '

### This target is not supported in this version
#gwl : ph
#	if test -d GWW ; then \
	( cd GWW ; $(MAKE) TLDEPS= all || exit 1 ) ; fi

### This target is not supported in this version
#gipaw : pw
#	( cd install ; $(MAKE) -f plugins_makefile $@ || exit 1 )

### This target is not supported in this version
#d3q : pw ph
#	( cd install ; $(MAKE) -f plugins_makefile $@ || exit 1 )

ld1 : bindir liblapack libfft libla mods libs
	if test -d atomic ; then \
	( cd atomic ; $(MAKE) TLDEPS= all || exit 1 ) ; fi

upf : libfft libla mods libs liblapack 
	if test -d upftools ; then \
	( cd upftools ; $(MAKE) TLDEPS= all || exit 1 ) ; fi

pw_export : libiotk bindir libfft mods libs pw
	if test -d PP ; then \
	( cd PP ; $(MAKE) TLDEPS= pw_export.x || exit 1 ) ; fi

### This target is not supported in this version
#xspectra : bindir libfft mods libs pw
#	if test -d XSpectra ; then \
#	( cd XSpectra ; $(MAKE) TLDEPS= all || exit 1 ) ; fi

### This target is not supported in this version
#couple : pw cp
#	if test -d COUPLE ; then \
#	( cd COUPLE ; $(MAKE) TLDEPS= all || exit 1 ) ; fi

### This target is not supported in this version
# EPW needs to invoke make twice due to a Wannier90 workaround
#epw: pw ph ld1
#	if test -d EPW ; then \
#	( cd EPW ; $(MAKE) all ; $(MAKE) all || exit 1; \
#		cd ../bin; ln -fs ../EPW/bin/epw.x . ); fi

### This target is not supported in this version
#gui :
#	@echo 'Check "PWgui-6.0/README" how to access the Graphical User Interface'

### This target is not supported in this version
#examples : touch-dummy
#	( cd install ; $(MAKE) -f plugins_makefile $@ || exit 1 )

pwall : pw neb pp pwcond 

all   : pwall ld1 upf

###########################################################
# Auxiliary targets used by main targets:
# compile modules, libraries, directory for binaries, etc
###########################################################

libla : touch-dummy liblapack
	( cd LAXlib ; $(MAKE) TLDEPS= all || exit 1 )

libfft : touch-dummy
	( cd FFTXlib ; $(MAKE) TLDEPS= all || exit 1 )

mods : libiotk libla libfft
	( cd Modules ; $(MAKE) TLDEPS= all || exit 1 )

libs : mods
	( cd clib ; $(MAKE) TLDEPS= all || exit 1 )

lrmods : libs libla libfft 
	( cd LR_Modules ; $(MAKE) TLDEPS= all || exit 1 )

bindir :
	test -d bin || mkdir bin

#############################################################
# Targets for external libraries
############################################################

libblas : touch-dummy
	cd install ; $(MAKE) -f extlibs_makefile $@

liblapack: touch-dummy
	cd install ; $(MAKE) -f extlibs_makefile $@

libiotk: touch-dummy
	cd install ; $(MAKE) -f extlibs_makefile $@

# In case of trouble with iotk and compilers, add
# FFLAGS="$(FFLAGS_NOOPT)" after $(MFLAGS)


#########################################################
# plugins
#########################################################

### This target is not supported in this version
#w90: bindir liblapack
#	( cd install ; $(MAKE) -f plugins_makefile $@ || exit 1 )

### This target is not supported in this version
#want : touch-dummy
#	( cd install ; $(MAKE) -f plugins_makefile $@ || exit 1 )

### This target is not supported in this version
#SaX : touch-dummy
#	( cd install ; $(MAKE) -f plugins_makefile $@ || exit 1 )

### This target is not supported in this version
#yambo: touch-dummy
#	( cd install ; $(MAKE) -f plugins_makefile $@ || exit 1 )

### This target is not supported in this version
#yambo-devel: touch-dummy
#	( cd install ; $(MAKE) -f plugins_makefile $@ || exit 1 )

### This target is not supported in this version
#plumed: touch-dummy
#	( cd install ; $(MAKE) -f plugins_makefile $@ || exit 1 )

### This target is not supported in this version
#west: pw touch-dummy
#	( cd install ; $(MAKE) -f plugins_makefile $@ || exit 1 )

touch-dummy :
	$(dummy-variable)

#########################################################
# "make links" produces links to all executables in bin/
# while "make inst" INSTALLDIR=/some/place" links all
# available executables to /some/place/ (must exist and
# be writable), prepending "qe_" to all executables (e.g.:
# /some/place/qe_pw.x). This allows installation of QE
# into system directories with no danger of name conflicts
#########################################################

inst : 
	( for exe in */*/*.x */bin/* ; do \
	   file=`basename $$exe`; if test "$(INSTALLDIR)" != ""; then \
		if test ! -L $(PWD)/$$exe; then \
			ln -fs $(PWD)/$$exe $(INSTALLDIR)/qe_$$file ; fi ; \
		fi ; \
	done )

# Contains workaround for name conflicts (dos.x and bands.x) with WANT
links : bindir
	( cd bin/ ; \
	rm -f *.x ; \
	for exe in ../*/*/*.x ../*/bin/* ; do \
	    if test ! -L $$exe ; then ln -fs $$exe . ; fi \
	done ; \
	[ -f ../WANT/wannier/dos.x ] && \
		ln -fs ../WANT/wannier/dos.x ../bin/dos_want.x ; \
	[ -f ../PP/src/dos.x ] &&  \
		ln -fs ../PP/src/dos.x ../bin/dos.x ; \
	[ -f ../WANT/wannier/bands.x ] && \
		ln -fs ../WANT/wannier/bands.x ../bin/bands_want.x ; \
	[ -f ../PP/src/dos.x ] &&  ln -fs ../PP/src/bands.x ../bin/bands.x ; \
	[ -f ../W90/wannier90.x ] &&  ln -fs ../W90/wannier90.x ../bin/wannier90.x ;\
	)

#########################################################
# 'make install' works based on --with-prefix
# - If the final directory does not exists it creates it
#########################################################

install : touch-dummy
	@if test -d bin ; then mkdir -p $(PREFIX)/bin ; \
	for x in `find . -path ./test-suite -prune -o -name *.x -type f` ; do \
		cp $$x $(PREFIX)/bin/ ; done ; \
	fi
	@echo 'Quantum ESPRESSO binaries installed in $(PREFIX)/bin'

#########################################################
# Run test-suite for numerical regression testing
# NB: it is assumed that reference outputs have been 
#     already computed once (usualy during release)
#########################################################

### This target is not supported in this version
#test-suite: pw touch-dummy
#	( cd install ; $(MAKE) -f plugins_makefile $@ || exit 1 )

#########################################################
# Other targets: clean up
#########################################################

# remove object files and executables
clean : 
	touch make.inc 
	for dir in \
		LAXlib FFTXlib Modules PP PW \
		NEB PWCOND \
		atomic clib LR_Modules pwtools upftools \
		dev-tools extlibs \
	; do \
	    if test -d $$dir ; then \
		( cd $$dir ; \
		$(MAKE) TLDEPS= clean ) \
	    fi \
	done
	- @(cd install ; $(MAKE) -f plugins_makefile clean)
	- @(cd install ; $(MAKE) -f extlibs_makefile clean)
	- /bin/rm -rf bin/*.x tmp

# remove files produced by "configure" as well
veryclean : clean
	- @(cd install ; $(MAKE) -f plugins_makefile veryclean)
	- @(cd install ; $(MAKE) -f extlibs_makefile veryclean)
	- rm -rf install/patch-plumed
	- cd install ; rm -f config.log configure.msg config.status \
		CPV/version.h ChangeLog* intel.pcl */intel.pcl
	- rm -rf include/configure.h install/make_wannier90.inc
	- cd install ; rm -fr autom4te.cache
	- cd pseudo; ./clean_ps ; cd -
	- cd install; ./clean.sh ; cd -
	- cd include; ./clean.sh ; cd -
	- rm -f espresso.tar.gz
	- rm -rf make.inc

# remove everything not in the original distribution 
distclean : veryclean
	( cd install ; $(MAKE) -f plugins_makefile $@ || exit 1 )

tar :
	@if test -f espresso.tar.gz ; then /bin/rm espresso.tar.gz ; fi
	# do not include unneeded stuff 
	find ./ -type f | grep -v -e /.svn/ -e'/\.' -e'\.o$$' -e'\.mod$$'\
		-e /.git/ -e'\.a$$' -e'\.d$$' -e'\.i$$' -e'_tmp\.f90$$' -e'\.x$$' \
		-e'~$$' -e'\./GUI' -e '\./tempdir' | xargs tar rvf espresso.tar
	gzip espresso.tar

#########################################################
# Tools for the developers
#########################################################
tar-gui :
	@if test -d GUI/PWgui ; then \
	    cd GUI/PWgui ; \
	    $(MAKE) TLDEPS= clean svninit pwgui-source; \
	    mv PWgui-*.tgz ../.. ; \
	else \
	    echo ; \
	    echo "  Sorry, tar-gui works only for svn sources !!!" ; \
	    echo ; \
	fi

tar-qe-modes :
	@if test -d GUI/QE-modes ; then \
	    cd GUI/QE-modes ; \
	    $(MAKE) TLDEPS= veryclean tar; \
	    mv QE-modes-*.tar.gz ../.. ; \
	else \
	    echo ; \
	    echo "  Sorry, tar-qe-modes works only for svn sources !!!" ; \
	    echo ; \
	fi

# NOTICE about "make doc": in order to build the .html and .txt
# documentation in Doc, "tcl", "tcllib", "xsltproc" are needed;
# in order to build the .pdf files in Doc, "pdflatex" is needed;
# in order to build html files for user guide and developer manual,
# "latex2html" and "convert" (from Image-Magick) are needed.
doc : touch-dummy
	if test -d Doc ; then \
	( cd Doc ; $(MAKE) TLDEPS= all ) ; fi
	for dir in */Doc; do \
	( if test -f $$dir/Makefile ; then \
	( cd $$dir; $(MAKE) TLDEPS= all ) ; fi ) ;  done

doc_clean :
	if test -d Doc ; then \
	( cd Doc ; $(MAKE) TLDEPS= clean ) ; fi
	for dir in */Doc; do \
	( if test -f $$dir/Makefile ; then \
	( cd $$dir; $(MAKE) TLDEPS= clean ) ; fi ) ;  done

depend: libiotk version
	@echo 'Checking dependencies...'
	- ( if test -x install/makedeps.sh ; then install/makedeps.sh ; fi)
# update file containing version number before looking for dependencies

version:
	- ( cd Modules; make version )

