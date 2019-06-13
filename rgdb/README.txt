rgdb.pl:

I use this to debug C-programs on small (eg. raspberry) computers 
when I cannot use gdbserver (alone), eg:

* debug a c-programm running on an tiny arm system
* the program was cross-compiled on an linux/intel build-server
* I use visual studio code on my local (possibly windows) computer to step through

rgdb in this case can be set up to map source paths on my local system 
to pathes on the build server on-the-fly. Use the source, Luke..

rgdb uses ssh + authentication by agent ( ssh-add ~/.ssh/my_key.rsa .. )

On Windows, I use strawberry perl + WSL.
