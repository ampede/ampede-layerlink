Do Linear Sequencing
--------------------

* line things up in tasks
* the file system is your work area -- keep it clean
   * directories are unordered, though
* spend time on setup
   * it's okay to get the tools you need
   * it's okay to configure tools
* don't play in the global space
* eliminate unnecessary dependencies
* decide freshness manually
* ruby source should read like English
* avoid conditional statements
   * duplicate tasks instead
* don't write general purpose code for special purpose needs
* use rake, but execute tasks explicitly
* don't use rake to handle file dependencies
   * instead, do manual sequencing via tasks
* don't be afraid to duplicate code!
   * generic code is difficult to optimize

**Remember, don't make anything until it is requested. Then, make it very fast.**

* prefer straight-line code, simple sequencing
* keep unique code together
   * library code should be generic
   * don't spread project-specific code around in multiple files
      * it should be possible to determine exactly what a given task does by looking in a single source file
* don't reinvent the wheel
   * use xcodebuild to compile and link object files
      * have xcodebuild operate in a fresh directory
      * only have one .xcode file for each product
         * use build styles to optimize for debug, test, and release builds