# DPF.Android.Native.Components
Port of D.P.F.Android.Native.Components to support Embarcadero C++ Builder 9 (Seattle)

Original D.P.F.Android.Native.Components can be found at:
  http://sourceforge.net/projects/dpfdelphiandroid
  
Here is the port to Embarcadero BDS 9 (Seattle) plus several changes:
+ Package is split to runtime and designtime: its impossible to use single package in C++
+ Source corrections to Seattle JNI
+ All "deprecated" symbols changed
+ Packages configured to be correctly used in C++ environment (correct header and libs in right places)
- Property "Frame" removed from xLayout components: its impossible to use them in C++ (Frame moved to public section)

Hope you find its usefull :)

PS: I cant test it on Delphi, so not sure its ported correctly but it works in C++

PPS: Packages made in Delphi projects (dproj) due to error in ilink32 which makes invalid "bpi" import library for runtime package.
