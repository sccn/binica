Extended Infomax ICA Binary compiled for Windows 10 x64
Based on original source win32 Visual Studio 6 (2001) source by Enghoff (http://cnl.salk.edu/~enghoff/download1/)
Modified by Ernest Pedapati and Ellen Russo
ernest.pedapati [at] gmail [dot] com

Instructions:

1. place binica.exe, libiomp5md.dll, libiompstubs5md.dll into the EEGLAB folder: eeglab\functions\resources
	the additional libraries (dll) are from the Intel Math Kernal Library Redistibutable. You can download the entire library at 
	https://software.intel.com/en-us/mkl

2. then replace the line in icadefs.m (line 141) found in the eeglab\functions\sigprocfunc

	ICABINARY = fullfile(eeglab_p, 'functions', 'resources', 'binica.exe'); 


3. We currently have tested this binary under Windows 7/Windows 10 with Matlab 2012+ and EEGLAB 14.2b.
   The version can be used in a parfor loop for parallel computing.

parfor i = 1 : length(EEGArr)
      
	EEG = EEGArr(i);

  	s.EEG_postica = pop_runica(EEG,'icatype','binica', 'extended',1,'interupt','on','pca', rank); % calculate rank to correct for channel interpolation

	EEGArr(i) = EEG;

end