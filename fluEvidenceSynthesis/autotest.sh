#!/bin/bash

# Always run at least once
R -e 'Rcpp::compileAttributes(".",verbose=TRUE)';
# Should actually move needed header in inst/include/fluEvidenceSynthesis.h insted of using echo
echo -e "#include \"rcppwrap.hh\"\n$(cat src/RcppExports.cpp)" > src/RcppExports.cpp;
R CMD check ../fluEvidenceSynthesis

# This script depends on inotify-hookable
inotify-hookable -t 1000 -i '*.o' -i '\..*' -w data -w src -w tests -f DESCRIPTION -w R -c "R -e 'Rcpp::compileAttributes(\".\",verbose=TRUE)' && echo '#include \"rcppwrap.hh\"\n$(cat src/RcppExports.cpp)' > src/RcppExports.cpp && R CMD check ../fluEvidenceSynthesis; sleep 10"
