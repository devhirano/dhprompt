# Whats this?

"dhprompt" is my private PS1 terminal enhancement.  
At first it only changing terminal color and line messages,  
But now a day it has some functions.  

- Auto logging: You lost logs? I lost always. So I added auto logging.
- Return code face: You can see return code is good or bad immediately. ┐(´д`)┌
- Auto git fetch: git fetch, git fetch, git fetch, oops.
- Show useful info: gateway interface, short username, short hostname, screen numbers and current time.

examples.
- username "devhirano" is long so omitted.
- hostname "hp" is short so not omitted.
- wlo1 is wireless lan interface name.
- dhprompt is directory name.
- s0 is screen display number.
- (master *=) is git-prompt function.

```
01:08 [devhir~@hp(wlo1)] dhprompt [s0] (master *=) $ 
01:08 dhprompt $ 
01:08 dhprompt $ 
01:08 dhprompt $ ls -la
total 28
drwxrwxr-x 3 devhirano devhirano  4096  1月 23 01:07 .
drwxrwxr-x 8 devhirano devhirano  4096 12月 28 02:06 ..
-rw-r--r-- 1 devhirano devhirano 10577  1月 23 00:46 dh.sh
drwxrwxr-x 8 devhirano devhirano  4096  1月 23 00:48 .git
-rw-rw-r-- 1 devhirano devhirano   610  1月 23 01:07 README.md

```

- If return code is non zero, random KAO-MOJI is displayed

```
01:14 dhprompt $ echo hi
hi
01:14 [devhir~@hp(wlo1)] dhprompt [s0] (master *=) $ 

01:13 dhprompt $ badcommand
badcommand: command not found
01:13 [devhir~@hp(wlo1)] dhprompt [s0] ┐(´д`)┌ (master *=) $ 
```

# Support OS

- today only Ubuntu 16.04 with Bash(Dash)


# How to enable dhprompt

```
https://github.com/devhirano/dhprompt.git
cd dhprompt
./setup.sh
```

And then you can see the enchaned console next login :)


# How to disable dhprompt

dhprompt is read from ~/.bashrc like following line.  

```
source <dhprompt cloned directory>/dh.sh
```

So you can delete line or uncomment.

