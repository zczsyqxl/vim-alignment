# vim-alignment
---

### Introduction
A Vim plugin used to do alignment for MACROS, or via the char/string inputted by user.

### Feature
+ **Vim-Script, RegExp**
+ Support to number parameter before the command.
+ Support to regular expression in the string inputted by user.

### Usage
+ Align ***MACRO*** definition:&ensp;&ensp;<kbd>\<leader>**l**m</kbd>  
    ![Macro](https://raw.githubusercontent.com/zczsyqxl/my-images/main/imgMacro.gif)
+ Align **with** a ***single char***[^1]:&ensp;&ensp;<kbd>[count]\<leader>**l**{char}</kbd>[^2]  
    ![SC](https://raw.githubusercontent.com/zczsyqxl/my-images/main/imgSC.gif)
+ Align **with** a ***string***[^3]:&ensp;&ensp;<kbd>[count]\<leader>**l**s</kbd>[^4]  
    ![bs](https://raw.githubusercontent.com/zczsyqxl/my-images/main/img/bs.gif)
+ Align **after** a ***string***[^3]:&ensp;&ensp;<kbd>[count]\<leader>**l**e</kbd>[^4]  
    ![as](https://raw.githubusercontent.com/zczsyqxl/my-images/main/img/as.gif)

### Example  
![wh](https://raw.githubusercontent.com/zczsyqxl/my-images/main/imgwh.gif)

    
    

[^1]: Except **'m','e','s'**, the **{char}** follow **'l'** will be used to do the alignment.  
[^2]: **[count]** represents the occurrence times of the ***single char***.  
[^3]: Support regular expression, can be a **single char**.  
[^4]: **[count]** is optional, default value is **1**. When the ***string*** is a ***single char***, the **[count]** represents the occurrence times of the ***single char***, otherwise, **[count]** represents the column number which is the alignment location.  




