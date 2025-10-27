#tech
## 宏定义连接符

#### 示例代码
```cpp
/* escape hatches */  
typedef struct escape_hatch_t {  
    const char *name;  
    int *val;  
} escape_hatch_t;

#define declare_escape_hatch(name) \  
    extern int name; \  
    struct escape_hatch_t st_##name = {    #name, &name };
```
#### AI解
1. `#define declare_escape_hatch(name)` 定义了一个带参数的宏，参数为`name`
2. 宏展开后会生成两部分内容：      
    - `extern int name;` 声明一个外部整数变量，变量名由参数`name`指定
    - `struct escape_hatch_t st_##name = { #name, &name };` 定义一个`escape_hatch_t`结构体实例
        - 结构体变量名是`st_`加上参数`name`（通过`##`连接）
        - 初始化值为两个元素：字符串化的`name`（通过`#name`实现）和变量`name`的地址
```cpp
decalre_escape_hatch(name);
// 展开为
extern int name;
struct escape_hatch st_name= {"name", &name}
```