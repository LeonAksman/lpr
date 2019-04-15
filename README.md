Longitudinal Pattern Recognition (LPR) Toolbox

INTRODUCTION

This MATLAB toolbox has been developed as part of my PhD work, which focussed on developing a 
feature construction method that combined longitudinal and cross-sectional structural neuroimaging data. 
As a result, the code is intended to work with neuroimaging data, though in principle any data can be used, with minor modifications. 

This is intended to be a programmatic toolbox for classification using both cross-sectional and longitudinal information. I recommend the [PRoNTo](http://www.mlnl.cs.ucl.ac.uk/pronto/) toolbox for if you are looking for a GUI based toolbox that is focussed on pattern recognition using cross-sectional neuroimaging information. 

This code relies on:

- [NIFTI toolbox](http://uk.mathworks.com/matlabcentral/fileexchange/8797-tools-for-nifti-and-analyze-image)
- [LIBSVM library](https://www.csie.ntu.edu.tw/~cjlin/libsvm/)
- [GPML toolbox](http://www.gaussianprocess.org/gpml/code/matlab/doc/)

If you use this code, please cite [our paper](https://doi.org/10.1002/hbm.23317):

Aksman, L.M., Lythgoe, D.J., Williams, S.C.R., Jokisch, M., Mönninghoff, C., Streffer, J., Jöckel, K.-H., Weimar, C., Marquand, A.F., 2016. Making use of longitudinal information in pattern recognition. Hum. Brain Mapp. 37, 4385–4404. https://doi.org/10.1002/hbm.23317


GETTING STARTED 

The code is designed to be simple to understand and use. 
There are several well-commented demos that can be run (in the demo_analysis folder) on the data that has been provided 
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

You can also run each of these functions by passing 'debug' as the single parameter.
For example:

>> demo_ltcpca('debug')

which will not perform nested cross-validation via parfor, 
making it easier to step through the code in debugger.


POTENTIAL PROBLEMS

This code was developed in Linux using MATLAB R2013b. 
It may have dependencies on some MathWorks toolboxes, which may not be strictly necessary. 
If they pose a problem for you, please contact me.


LICENSE

This toolbox is licensed under GPLv3. Please see the LICENSE.txt file included.


CONTACT

Please email me with questions, suggestions or improvements.

Leon Aksman
l.aksman@ucl.ac.uk
