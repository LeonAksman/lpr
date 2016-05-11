Longitudinal Pattern Recognition (LPR) Toolbox

INTRODUCTION

This MATLAB toolbox has been developed as part of my PhD work, which focussed on developing a 
feature construction method that combined longitudinal and cross-sectional structural neuroimaging data. 
As a result, the code is intended to work with neuroimaging data, though in principle any data can be used, with minor modifications. 

This is not a complete neuroimage-based pattern recognition toolbox. 
I recommend the PRoNTo toolbox for that:
http://www.mlnl.cs.ucl.ac.uk/pronto/


This code also uses:

- NIFTI toolbox (http://uk.mathworks.com/matlabcentral/fileexchange/8797-tools-for-nifti-and-analyze-image)
- LIBVM library (https://www.csie.ntu.edu.tw/~cjlin/libsvm/)
- GPML toolbox  (http://www.gaussianprocess.org/gpml/code/matlab/doc/)


GETTING STARTED 

The code is designed to be simple to understand and use. 
There are several demos that can be run (in the demo_analysis folder) on the data that has been provided 
(in the demo_data folder). 

Download and install the code locally, then in MATLAB run:

>> demo_crossSectional() 

This will run a cross-sectional style analysis using the data in demo_data

Then you can run different version of our proposed method.
To run the most general version (LTC-PCA), run:

>> demo_ltcpca()

To run unbalanced LM-PCA on the same data, run:

>> demo_lmpca_long()

or

>> demo_lmpca_short()

to try long follow-ups or short follow-ups between subjects' samples.

You can also run each of these function by passing 'debug' as the single parameter.
For example:

>> demo_ltcpca('debug')

which will not perform nested cross-validation via parfor, 
making it easier to step through the code in debugger.


POTENTIAL PROBLEMS

This code was developed in Linux using MATLAB R2013b. 
It may have dependencies on some MathWorks toolboxes. T
Those dependencies are not strictly necessary. If they pose a problem for you, please contact me.


CONTACT

Please email me with questions, suggestions or improvements.

Leon Aksman
leon.aksman@kcl.ac.uk
