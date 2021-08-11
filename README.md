# file-utils
Some useful functions for handling files (for indoor use)

<pre>
Usage: file_utils &lt;command&gt; [arguments]

Global options:
  -h, --help       Print this usage information.
  -v, --version

Available commands:
  copy-latest-files    Copy the latest files
  keeps-latest-files   Keeps the latest files

Run "file_utils help &lt;command&gt;" for more information about a command.
</pre>

<pre>
# Keeps the latest files

Usage: file_utils keeps-latest-files &lt;path&gt; &lt;number of files&gt; [minimum days=15]
  -h, --help    Print this usage information.
</pre>

<pre>
# Copy the latest files

Usage: file_utils copy-latest-files &lt;path&gt; &lt;destination path&gt; [number of files=1]
  -h, --help    Print this usage information.
</pre> 
